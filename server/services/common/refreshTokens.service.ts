import type { Context } from "moleculer";
import { v4 as uuidv4 } from "uuid";
import { Config } from "../../common";
import { ServiceError } from "../../core/errors/global";
import type { RefreshToken } from "../../entities/refreshToken.entity";
import { DbMixin } from "../../mixins/db";
import { MongoObjectId } from "../../types/common";
import type {
	ObjectId,
	TokenGenerateParams,
	TokenServiceSchema,
	TokenThis,
	TokenVerifyParams,
} from "../../types/common";

const AuthService: TokenServiceSchema = {
	name: "refreshTokens",
	authToken: Config.REFRESH_TOKENS_AUTH_TOKEN,
	mixins: [DbMixin("refresh_tokens")],

	settings: {
		fields: ["userId", "token", "expires"],
		// Validator for entity
		entityValidator: {
			userId: [{ type: "objectID", ObjectID: MongoObjectId }, { type: "string" }],
			token: { type: "string" },
			expires: { type: "date" },
		},

		indexes: [
			{
				token: 1,
				unique: true,
			},
			{
				userId: 1,
				unique: true,
			},
		],
	},

	actions: {
		verifyToken: {
			rest: "",
			restricted: ["customers", "drivers", "staffs"],
			params: {
				refreshToken: { type: "string" },
			},
			cache: {
				keys: ["refreshToken"],
				ttl: 60,
			},
			async handler(this: TokenThis, ctx: Context<TokenVerifyParams>): Promise<string> {
				const params = this.sanitizeParams(ctx, ctx.params);
				const { refreshToken } = params;

				let result = await this.adapter.findOne({ token: refreshToken });
				if (!result) {
					throw new ServiceError("Invalid refresh token.", 403);
				}

				if (this.checkExpired(result)) {
					throw new ServiceError(
						"Refresh token expired. Please make a new login request",
						403,
					);
				}
				result = await this.transformDocuments(ctx, {}, result);
				return result;
			},
		},

		generate: {
			rest: "",
			restricted: ["customers", "drivers", "staffs"],
			params: {
				userId: [{ type: "objectID", ObjectID: MongoObjectId }, { type: "string" }],
				ttl: { type: "number", default: 7 * 24 * 60 * 60 },
			},
			async handler(this: TokenThis, ctx: Context<TokenGenerateParams>): Promise<string> {
				const { userId, ttl } = ctx.params;

				const token = await this.adapter
					.findOne({ userId: new MongoObjectId(userId) })
					.then(async (refreshToken: RefreshToken) => {
						// If refresh token exists
						if (refreshToken) {
							// If refresh token expired
							// Remove refresh token
							if (this.checkExpired(refreshToken)) {
								await this.actions.remove(
									{ id: refreshToken._id },
									{
										parentCtx: ctx,
									},
								);
							} else {
								return refreshToken.token;
							}
						}

						const newRefreshToken = this.generateRefreshToken(userId, ttl);
						const entity = await this.actions.create(newRefreshToken, {
							parentCtx: ctx,
						});
						return entity.token;
					})
					.catch((err: any) => {
						throw new ServiceError(err.message, 500);
					});

				return token;
			},
		},

		create: {
			restricted: ["customers", "drivers", "staffs"],
			rest: "",
			params: {
				userId: [{ type: "objectID", ObjectID: MongoObjectId }, { type: "string" }],
				token: { type: "string" },
				expires: { type: "date" },
				createdAt: { type: "date", optional: true },
				updatedAt: { type: "date", optional: true },
			},
		},

		update: {
			restricted: ["customers", "drivers", "staffs"],
			rest: "",
			params: {
				token: { type: "string" },
				expires: { type: "date" },
			},
		},
		remove: {
			restricted: ["customers", "drivers", "staffs"],
			rest: "",
		},

		find: false,
		get: false,
		list: false,
	},

	events: {},

	methods: {
		checkExpired(this: TokenThis, refreshToken: RefreshToken): boolean {
			return refreshToken.expires < new Date();
		},

		generateRefreshToken(this: TokenThis, userId: ObjectId, ttl: number): RefreshToken {
			const expiredAt = new Date();
			expiredAt.setSeconds(expiredAt.getSeconds() + ttl);

			const refreshToken: RefreshToken = {
				userId,
				token: uuidv4(),
				expires: expiredAt,
			};

			return refreshToken;
		},
	},

	beforeEntityCreate(entity: RefreshToken) {
		entity.userId = new MongoObjectId(entity.userId);
		entity.createdAt = new Date();
		entity.updatedAt = new Date();
		return entity;
	},

	beforeEntityUpdate(entity: RefreshToken) {
		entity.userId = new MongoObjectId(entity.userId);
		entity.updatedAt = new Date();
		return entity;
	},
};

export default AuthService;
