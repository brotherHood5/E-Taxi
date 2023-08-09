import { pick } from "lodash";
import type { Context, Errors, Service, ServiceSchema } from "moleculer";
import type { ApiSettingsSchema, IncomingRequest, Route } from "moleculer-web";
import ApiGateway from "moleculer-web";
import type {
	ApiGatewayMeta,
	AuthResolveTokenParams,
	AuthValidateRoleParams,
	IUserBase,
} from "../../types";

export default function apiAuthMixin(service: string): Partial<ServiceSchema> {
	const schema: Partial<ServiceSchema> = {
		methods: {
			async rejectAuth(
				this: Service<ApiSettingsSchema>,
				ctx: Context<Record<string, unknown>, ApiGatewayMeta>,
				error: Errors.MoleculerError,
			): Promise<unknown> {
				if (ctx.meta.user) {
					const context = pick(
						ctx,
						"nodeID",
						"id",
						"event",
						"eventName",
						"eventType",
						"eventGroups",
						"parentID",
						"requestID",
						"caller",
						"params",
						"meta",
						"locals",
					);
					const action = pick(ctx.action, "rawName", "name", "params", "rest");
					const logInfo = {
						action: "AUTH_FAILURE",
						details: {
							error,
							context,
							action,
							meta: ctx.meta,
						},
					};
					this.logger.error(logInfo);
				}
				return Promise.reject(error);
			},

			/**
			 * Authenticate the request. It check the `Authorization` token value in the request header.
			 * Check the token value & resolve the user by the token.
			 * The resolved user will be available in `ctx.meta.user`
			 */
			async authenticate(
				this: Service<ApiSettingsSchema>,
				ctx: Context,
				route: Route,
				req: IncomingRequest,
			): Promise<any | null> {
				// Read the token from header
				const auth = req.headers.authorization;

				if (auth) {
					const type = auth.split(" ")[0];
					let token: string | undefined;
					if (type === "Token" || type === "Bearer") {
						[, token] = auth.split(" ");
					}
					if (token) {
						try {
							const user = await ctx.call<
								IUserBase | undefined,
								AuthResolveTokenParams
							>(`${service}.resolveToken`, { token });
							if (user && user.active) {
								return await Promise.resolve(user);
							}
						} catch (error) {
							/* empty */
						}
					}
				}

				// No token. Anonymous access is allowed.
				return null;
			},

			/**
			 * Authorize the request. Check that the authenticated user has right to access the resource.
			 *
			 * PLEASE NOTE, IT'S JUST AN EXAMPLE IMPLEMENTATION. DO NOT USE IN PRODUCTION!
			 */
			async authorize(
				this: Service<ApiSettingsSchema>,
				ctx: Context<null, ApiGatewayMeta>,
				route: Route,
				req: IncomingRequest,
			): Promise<unknown> {
				// Get the authenticated user.
				const { user } = ctx.meta;

				// It check the `auth` property in action schema.
				if (!req.$action.auth || req.$action.auth === false) {
					return Promise.resolve(null);
				}

				// Check logged user
				if (!user) {
					return this.rejectAuth(
						ctx,
						new ApiGateway.Errors.UnAuthorizedError(
							ApiGateway.Errors.ERR_NO_TOKEN,
							null,
						),
					);
				}

				// Validate roles
				const aroles = Array.isArray(req.$action.roles)
					? req.$action.roles
					: [req.$action.roles];
				const oroles = Array.isArray(req.$route.opts.roles)
					? req.$route.opts.roles
					: [req.$route.opts.roles];
				const allRoles = [...aroles, ...oroles].filter(Boolean);

				const roles = [...new Set(allRoles)];

				const valid = await ctx.call<boolean, AuthValidateRoleParams>(
					`${service}.validateRole`,
					{ roles },
					{ parentCtx: ctx },
				);
				if (!valid) {
					return this.rejectAuth(
						ctx,
						new ApiGateway.Errors.UnAuthorizedError("ERR_NO_RIGHTS", null),
					);
				}

				return Promise.resolve(ctx);
			},
		},
	};

	return schema;
}
