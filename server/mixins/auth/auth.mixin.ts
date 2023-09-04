import bcrypt from "bcryptjs";
import _ from "lodash";
import type { ActionParams, Context } from "moleculer";
import { Config } from "../../common";
import { ServiceError } from "../../core/errors/global";
import type { RefreshToken } from "../../entities/refreshToken.entity";
import { generateJWT, verifyJWT } from "../../helpers/jwt.helper";
import { UserRole } from "../../types/common";
import type { ApiGatewayMeta, IUserBase, UserAuthMeta } from "../../types/common";
import type {
	AuthLoginParams,
	AuthMixinSchema,
	AuthRefreshTokenParams,
	AuthResendOtpParams,
	AuthResolveTokenParams,
	AuthSignupParams,
	AuthThis,
	AuthValidateRoleParams,
	AuthVerifyOtpParams,
} from "../../types/mixin/auth";

// -------------------------------------
const phoneNumberRegex = /^0[0-9]{9}$/;
const passwordRegex = /^(?=.*?[A-Z])(?=.*?[a-z])(?=.*?[0-9])(?=.*?[#?!@$%^&*-]).{8,}$/;

const baseAuthParam: ActionParams = {
	phoneNumber: {
		type: "string",
		min: 10,
		max: 10,
		pattern: phoneNumberRegex,
		singleLine: true,
		trim: true,
		messages: {
			stringPattern: "Phone number is invalid. Valid format: 0xxxxxxxxx",
		},
	},
	password: {
		type: "string",
		min: 8,
		max: 64,
		trim: true,
		singleLine: true,
		pattern: passwordRegex,
		messages: {
			stringPattern:
				"Password is invalid. Valid format: 8-64 characters, at least 1 uppercase letter, 1 lowercase letter, 1 number and 1 special character",
		},
	},
};

const verifyOtpParam: ActionParams = {
	phoneNumber: baseAuthParam.phoneNumber,
	otp: {
		type: "string",
		min: 6,
		max: 6,
		trim: true,
		singleLine: true,
		pattern: /^[0-9]{6}$/,
		messages: {
			pattern: "OTP is invalid",
		},
	},
};

const AuthMixin: AuthMixinSchema = {
	settings: {},

	dependencies: ["refreshTokens"],

	actions: {
		signup: {
			rest: "POST /signup",
			auth: false,
			params: baseAuthParam,
			async handler(this: AuthThis, ctx: Context<AuthSignupParams>): Promise<any> {
				const { phoneNumber, password } = ctx.params;

				// Check if user exists
				const user = <IUserBase>await this.adapter.findOne({ phoneNumber });
				if (user && user.enable) {
					throw new ServiceError("Phone number is existed!", 422, [
						{ field: "phoneNumber", message: "existed" },
					]);
				}

				// Hash password
				const passwordHash = this.hashPassword(password);
				let newUser: IUserBase = {
					phoneNumber,
					passwordHash,
					phoneNumberVerified: false,
					enable: true,
					active: true,
					roles: [],
				};

				newUser = await this.actions.create({ ...newUser }, { parentCtx: ctx });

				await this.actions.sendOtp({ phoneNumber }, { parentCtx: ctx });

				const doc = await this.transformDocuments(ctx, {}, newUser);

				// Generate access token
				const accessToken = await this.generateAccessToken(newUser);

				// Generate refresh token
				const refreshToken: string = await ctx.call("refreshTokens.generate", {
					userId: doc._id,
					ttl: this.settings.refreshTokenExpiry,
				});

				const otpExpiresSec = this.settings.otpExpireMin * 60;
				return { user: doc, accessToken, refreshToken, otpExpiresSec };
			},
		},

		login: {
			rest: "POST /login",
			auth: false,
			params: baseAuthParam,
			async handler(
				this: AuthThis,
				ctx: Context<AuthLoginParams, ApiGatewayMeta>,
			): Promise<any> {
				const { phoneNumber, password } = ctx.params;

				// Check if user exists
				const user = <IUserBase>await this.adapter.findOne({ phoneNumber });
				if (!user) {
					throw new ServiceError("Phone number or password is invalid!", 422, [
						{ field: "phoneNumber", message: "is not found" },
					]);
				} else if (!user.enable) {
					throw new ServiceError("Your account is blocked!", 422, [
						{ field: "phoneNumber", message: "is blocked" },
					]);
				} else if (!user.phoneNumberVerified) {
					throw new ServiceError("Your phone number is not verified!", 422, [
						{ field: "phoneNumber", message: "is not verified" },
					]);
				}
				// else if (user.active) {
				// 	throw new ServiceError("Your account is logged!", 422, [
				// 		{ field: "phoneNumber", message: "is logged" },
				// 	]);
				// }

				// Check password
				if (!this.verifyPassword(password, user.passwordHash)) {
					throw new ServiceError("Phone number or password is invalid!", 422, [
						{ field: "phoneNumber", message: "is not found" },
						{ field: "password", message: "wrong" },
					]);
				}
				const updatedUser = await ctx.call(
					`${this.name}.update`,
					{ id: user._id, active: true },
					{ parentCtx: ctx },
				);

				const doc = await this.transformDocuments(ctx, {}, updatedUser ?? user);
				if (doc.passwordHash) {
					delete doc.passwordHash;
				}

				// Generate access token
				const accessToken = await this.generateAccessToken(user);

				// Generate refresh token
				const refreshToken: string = await ctx.call("refreshTokens.generate", {
					userId: doc._id,
					ttl: this.settings.refreshTokenExpiry,
				});

				ctx.meta.$responseHeaders = {
					...ctx.meta.$responseHeaders,
					Authorization: `Bearer ${accessToken}`,
				};
				return { user: doc, accessToken, refreshToken };
			},
		},

		sendOtp: {
			visibility: "private",
			params: {
				phoneNumber: baseAuthParam.phoneNumber,
			},
			async handler(this: AuthThis, ctx: Context<any>): Promise<any> {
				const { phoneNumber } = ctx.params;
				const otp = this.generateOTP();
				const message = `Ma xac minh cua quy khach la ${`${otp.slice(0, 3)}-${otp.slice(
					3,
					6,
				)}`} (het han sau ${this.settings.otpExpireMin} phut)`;

				try {
					await this.cacheOtp(phoneNumber, otp);
				} catch (err) {
					throw new ServiceError(err.message, 422);
				}

				await this.broker.call("socket.notify", {
					provider: "sms",
					data: { to: phoneNumber, message },
				});

				return {
					message: "Sent otp to phone number successfully",
					debug: Config.NODE_ENV !== "development" ? undefined : { otp },
				};
			},
		},

		refreshToken: {
			rest: "POST /refresh-token",
			auth: false,
			params: {
				refreshToken: { type: "string" },
			},
			async handler(this: AuthThis, ctx: Context<AuthRefreshTokenParams>): Promise<any> {
				const refreshToken: RefreshToken = await ctx.call(
					"refreshTokens.verifyToken",
					ctx.params,
				);

				const user = await this.actions.get(
					{ id: refreshToken.userId.toString() },
					{ parentCtx: ctx },
				);

				const doc = await this.transformDocuments(ctx, {}, user);
				const accessToken = await this.generateAccessToken(doc);

				return {
					accessToken,
					refreshToken: refreshToken.token,
				};
			},
		},

		resolveToken: {
			rest: "POST /resolve-token",
			auth: false,
			params: {
				token: { type: "string" },
			},
			async handler(
				this: AuthThis,
				ctx: Context<AuthResolveTokenParams>,
			): Promise<IUserBase> {
				try {
					const { token } = ctx.params;
					const decoded = await verifyJWT(token, this.settings.accessTokenSecret);
					const json = _.pick(decoded, ["user"]) as { user: IUserBase };
					const user = await this.actions.get({ id: json.user._id }, { parentCtx: ctx });
					const result = await this.transformDocuments(ctx, {}, user);
					return result;
				} catch (err) {
					throw new ServiceError("Token is invalid!", 422, [
						{ field: "token", message: "is invalid" },
					]);
				}
			},
		},

		resendOtp: {
			rest: "GET /resend-otp",
			auth: true,
			params: {
				phoneNumber: baseAuthParam.phoneNumber,
			},
			async handler(
				this: AuthThis,
				ctx: Context<AuthResendOtpParams, UserAuthMeta>,
			): Promise<any> {
				const { phoneNumber } = ctx.params;

				const { user } = ctx.meta;
				if (user.phoneNumberVerified) {
					throw new ServiceError("Phone number is verified!", 422, [
						{ field: "phoneNumber", message: "is verified" },
					]);
				}

				const result = await this.actions.sendOtp({ phoneNumber }, { parentCtx: ctx });
				return result;
			},
		},

		verifyOtp: {
			rest: "GET /verify-otp",
			params: verifyOtpParam,
			async handler(
				this: AuthThis,
				ctx: Context<AuthVerifyOtpParams, UserAuthMeta>,
			): Promise<any> {
				const { phoneNumber, otp } = ctx.params;

				const user = (await this.adapter.findOne({ phoneNumber })) as IUserBase;
				if (user.phoneNumberVerified) {
					throw new ServiceError("Phone number is verified!", 422, [
						{ field: "phoneNumber", message: "is verified" },
					]);
				}

				const isVerified = await this.verifyOtp(phoneNumber, otp);
				if (isVerified) {
					await this.actions.update(
						{ id: user._id, phoneNumberVerified: true },
						{ parentCtx: ctx },
					);
					await this.broker.cacher?.del(phoneNumber);
					return {
						message: "Phone number is verified successfully",
					};
				}

				throw new ServiceError("OTP is invalid!", 422, [
					{ field: "otp", message: "is invalid" },
				]);
			},
		},

		validateRole: {
			params: {
				roles: [
					{ type: "array", items: "string", enum: Object.values(UserRole) },
					{ type: "enum", values: Object.values(UserRole) },
				],
			},
			handler(this: AuthThis, ctx: Context<AuthValidateRoleParams, UserAuthMeta>): boolean {
				const { roles } = ctx.params;
				const userRoles = ctx.meta.user.roles;
				return !roles || !roles.length || roles.some((r) => userRoles?.includes(r));
			},
		},

		logout: {
			rest: "GET /logout",
			auth: true,
			async handler(this: AuthThis, ctx: Context<any, UserAuthMeta>): Promise<any> {
				const { user } = ctx.meta;
				await this.actions.update({ id: user._id, active: false }, { parentCtx: ctx });
			},
		},
	},

	methods: {
		generateOTP() {
			return Math.floor(100000 + Math.random() * 900000).toString();
		},

		async cacheOtp(this: AuthThis, phoneNumber: string, otp: string) {
			const cacheOtp = await this.broker.cacher?.get(phoneNumber);
			if (cacheOtp) {
				throw new Error("Already sent otp to this phone number");
			}

			const result = await this.broker.cacher?.set(
				phoneNumber,
				{ otp },
				this.settings.otpExpireMin * 60,
			);
			return result;
		},

		async verifyOtp(this: AuthThis, phoneNumber: string, otp: string) {
			const cachedOtp = await this.broker.cacher?.get(phoneNumber);
			return cachedOtp?.otp === otp;
		},

		hashPassword(password: string): string {
			const salt = bcrypt.genSaltSync(Config.SALT);
			return bcrypt.hashSync(password, salt);
		},

		verifyPassword(this: AuthThis, password: string, hash: string): boolean {
			return bcrypt.compareSync(password, hash);
		},

		async generateAccessToken(this: AuthThis, user: IUserBase): Promise<string | undefined> {
			const token = await generateJWT(
				user,
				this.settings.accessTokenSecret,
				this.settings.accessTokenExpiry,
			);

			return token;
		},
	},

	started(): any {
		if (!this.broker.cacher) {
			return Promise.reject(new ServiceError("Cacher is not configured!", 500));
		}

		return Promise.resolve();
	},
};

export default AuthMixin;
