/* eslint-disable @typescript-eslint/no-non-null-assertion */
import bcrypt from "bcryptjs";
import { pick } from "lodash";
import type { ActionParams, Context } from "moleculer";
import { Config } from "../../common";
import { ServiceError } from "../../core/errors";
import type { RefreshToken, StaffEntity } from "../../entities";
import { generateJWT, verifyJWT } from "../../helpers/jwt.helper";
import { createTestStaffs } from "../../helpers/seed";
import { DbMixin } from "../../mixins";
import type {
	AuthRefreshTokenParams,
	AuthResolveTokenParams,
	AuthValidateRoleParams,
} from "../../types";
import type { ActionCreateParams, StaffsServiceSchema, StaffsThis } from "../../types/common/staff";
import type { UserAuthMeta } from "../../types/common/user";
import { UserRole } from "../../types/common/user";

const validateStaffBase: ActionParams = {
	username: {
		type: "string",
	},
	roles: {
		type: "array",
		items: "string",
		enum: Object.values(UserRole),
		optional: true,
	},
};

const StaffsService: StaffsServiceSchema = {
	name: "staffs",
	authToken: Config.STAFFS_AUTH_TOKEN,
	mixins: [DbMixin("staffs")],

	dependencies: ["refreshTokens"],

	settings: {
		// Available fields in the responses
		fields: ["_id", "fullName", "username", "roles", "createdAt", "updatedAt"],

		// Validator for the `create` & `insert` actions.
		entityValidator: {
			fullName: { type: "string", min: 3, max: 255, optional: true },
			username: {
				type: "string",
				optional: true,
			},
			roles: {
				type: "array",
				items: "string",
				enum: Object.values(UserRole),
				optional: true,
			},
			createdAt: { type: "date", optional: true },
			updatedAt: { type: "date", optional: true },
		},

		indexes: [{ username: 1 }],

		accessTokenSecret: Config.ACCESS_TOKEN_SECRET,
		accessTokenExpiry: Config.ACCESS_TOKEN_EXPIRY,

		refreshTokenExpiry: Config.REFRESH_TOKEN_EXPIRY || 24 * 60 * 60 * 7,
	},

	actions: {
		create: {
			restricted: ["api"],
			auth: true,
			roles: [UserRole.ADMIN],
			params: {
				...validateStaffBase,
				passwordHash: { type: "string" },
			},
			async handler(this: StaffsThis, ctx: Context<ActionCreateParams>) {
				ctx.params.roles = [UserRole.STAFF];
				const entity = await this._create(ctx, ctx.params);
				return entity;
			},
		},
		list: {
			restricted: ["api"],
			auth: true,
			// roles: [UserRole.ADMIN, UserRole.STAFF],
			cache: {
				ttl: 60 * 2, // 2min
			},
		},

		get: {
			restricted: ["api"],
			auth: true,
			roles: [UserRole.ADMIN, UserRole.STAFF],
		},

		update: {
			restricted: ["api"],
			auth: true,
			roles: [UserRole.ADMIN],
		},
		remove: {
			restricted: ["api"],
			auth: true,
			roles: [UserRole.ADMIN],
		},
		find: {
			restricted: ["api"],
			auth: true,
			roles: [UserRole.ADMIN, UserRole.STAFF],
		},

		login: {
			rest: "POST /login",
			params: {
				username: { type: "string" },
				password: { type: "string" },
			},
			async handler(this: StaffsThis, ctx: Context<any, any>) {
				const { username, password } = ctx.params;

				// Check if user exists
				const user = <StaffEntity>await this.adapter.findOne({ username });
				if (!user) {
					throw new ServiceError("Username or password is invalid!", 422, [
						{ field: "username", message: "is not found" },
					]);
				}

				// Check password
				if (!this.verifyPassword(password, user.passwordHash)) {
					throw new ServiceError("Username or password is invalid!", 422, [
						{ field: "username", message: "is not found" },
						{ field: "password", message: "wrong" },
					]);
				}

				const doc = await this.transformDocuments(ctx, {}, user);
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

		me: {
			restricted: ["api"],
			rest: "GET /me",
			auth: true,
			roles: [UserRole.STAFF],
			async handler(this: StaffsThis, ctx: Context<any, UserAuthMeta>) {
				const entity = await this._get(ctx, { id: ctx.meta.user._id });
				return this.transformDocuments(ctx, {}, entity);
			},
		},

		resolveToken: {
			rest: "POST /resolve-token",
			auth: false,
			params: {
				token: { type: "string" },
			},
			async handler(
				this: StaffsThis,
				ctx: Context<AuthResolveTokenParams>,
			): Promise<StaffEntity> {
				const { token } = ctx.params;
				const decoded = await verifyJWT(token, this.settings.accessTokenSecret!);
				const result = pick(decoded, ["user"]) as { user: StaffEntity };
				return result.user;
			},
		},

		refreshToken: {
			restricted: ["api"],
			rest: "POST /refresh-token",
			auth: false,
			params: {
				refreshToken: { type: "string" },
			},
			async handler(this: StaffsThis, ctx: Context<AuthRefreshTokenParams>): Promise<any> {
				this.logger.info("Resolve token:", ctx.params);

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

		validateRole: {
			restricted: ["api"],
			params: {
				roles: [
					{ type: "array", items: "string", enum: Object.values(UserRole) },
					{ type: "enum", values: Object.values(UserRole) },
				],
			},
			handler(this: StaffsThis, ctx: Context<AuthValidateRoleParams, UserAuthMeta>): boolean {
				const { roles } = ctx.params;
				const userRoles = ctx.meta.user.roles;
				return !roles || !roles.length || roles.some((r) => userRoles?.includes(r));
			},
		},
	},

	methods: {
		async seedDB(this: StaffsThis) {
			const staffs = createTestStaffs(10);
			await this.adapter.insertMany(staffs);
		},

		verifyPassword(this: StaffsThis, password: string, hash: string): boolean {
			return bcrypt.compareSync(password, hash);
		},

		async generateAccessToken(
			this: StaffsThis,
			staff: StaffEntity,
		): Promise<string | undefined> {
			const token = await generateJWT(
				staff,
				this.settings.accessTokenSecret!,
				this.settings.accessTokenExpiry!,
			);

			return token;
		},
	},

	beforeEntityCreate(entity: any) {
		entity.createdAt = new Date();
		entity.updatedAt = new Date();
		return entity;
	},

	beforeEntityUpdate(entity: any) {
		entity.updatedAt = new Date();
		return entity;
	},

	async started() {
		const res = await this.actions.login({
			username: "20127665",
			password: "Vinh1706!",
		});
		this.logger.warn("Staff:", res.accessToken);
	},
};

export default StaffsService;
