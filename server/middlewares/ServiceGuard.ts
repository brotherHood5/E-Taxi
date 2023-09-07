/* eslint-disable @typescript-eslint/return-await */
/* eslint-disable no-extra-bind */
import type { Context, Middleware } from "moleculer";
import { TokenMissingError } from "../core/errors/guard.service.error";

const ServiceGuard: Middleware = {
	localAction(next: any, action: Record<string, unknown>): any {
		if (action.restricted) {
			return (async (ctx: Context<string, Record<string, any>>) => {
				// Check the service auth token in Context meta
				const token = ctx.meta.$authToken;
				if (!token) {
					throw new TokenMissingError("Service token is missing");
				}

				// Verify token & restricted services
				await ctx.call("guard.check", { token, services: action.restricted });

				// Call the original handler
				return await next(ctx);
			}).bind(this);
		}

		return next;
	},

	// Wrap broker.call method
	call(next: any) {
		return (async (
			actionName: string,
			params: Record<string, any>,
			opts: Record<string, any> = {},
		) => {
			// Put the service auth token in the meta
			if (opts.parentCtx) {
				const { service } = opts.parentCtx;
				const token = service.schema.authToken;

				if (!opts.meta) {
					opts.meta = {};
				}

				opts.meta.$authToken = token;
			}

			// Call the original handler
			return await next(actionName, params, opts);
		}).bind(this);
	},
};

export default ServiceGuard;
