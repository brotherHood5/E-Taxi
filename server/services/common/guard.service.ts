import { sign, verify } from "jsonwebtoken";
import type { Context, ServiceSchema } from "moleculer";
import { Config } from "../../common";
import {
	ForbiddenServiceError,
	InvalidTokenError,
	TokenGenerationError,
} from "../../core/errors/guard.service.error";
import CleanCacheMixin from "../../mixins/cache.cleaner.mixin";

const GuardService: ServiceSchema = {
	name: "guard",
	mixins: [CleanCacheMixin(["guard"])],
	cacher: {
		type: "Redis",
		options: {
			maxParamsLength: 60,
		},
	},

	actions: {
		check: {
			params: {
				token: "string",
				services: {
					type: "array",
					items: "string",
				},
			},
			cache: {
				keys: ["token", "services"],
				ttl: 24 * 60 * 60, // 1 day
			},
			async handler(ctx: Context<Record<string, never>>) {
				const { token, services } = ctx.params;
				const isValid = await this.verifyJWT(ctx, token, services);
				return isValid;
			},
		},

		generate: {
			params: {
				service: "string",
			},
			async handler(ctx: Context<Record<string, never>>) {
				const { service } = ctx.params;
				if (Config.NODE_ENV !== "development") {
					this.logger.warn("Only for development!");
					return new ForbiddenServiceError("Only for development!");
				}
				const token = await this.generateJWT(service);
				return token;
			},
		},
	},

	methods: {
		async generateJWT(service: string) {
			return new this.Promise((resolve, reject) =>
				sign({ service }, Config.GUARD_JWT_SECRET, (err: any, token: any) => {
					if (err) {
						this.logger.warn("JWT token generation error:", err);
						return reject(new TokenGenerationError("Unable to generate token"));
					}

					return resolve(token);
				}),
			);
		},

		async verifyJWT(ctx: Context<Record<string, never>>, token: string, services: string[]) {
			return new this.Promise((resolve, reject) => {
				verify(token, Config.GUARD_JWT_SECRET, (err: any, decoded: any) => {
					if (err) {
						return reject(new InvalidTokenError("Invalid service token"));
					}
					this.logger.info("Decoded token:", decoded);
					if (services && services.indexOf(decoded.service) === -1) {
						return reject(
							new ForbiddenServiceError(
								services.length !== 0 && Config.NODE_ENV === "development"
									? `Allowed Services: ${services.join(", ")}`
									: "Forbidden",
							),
						);
					}

					return resolve(token);
				});
			});
		},
	},
};

export default GuardService;
