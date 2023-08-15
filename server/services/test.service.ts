/* eslint-disable @typescript-eslint/require-await */
/* eslint-disable object-shorthand */
/* eslint-disable @typescript-eslint/naming-convention */
import type { Context, Service, ServiceSchema } from "moleculer";

const MathService: ServiceSchema = {
	name: "math",
	events: {},
	actions: {
		login(ctx: Context<any, any>) {
			ctx.meta.user = {
				id: 2,
				detail: "You are authorized using login.",
				name: ctx.params.name,
			};
			ctx.options.parentCtx!.meta = ctx.meta;
			// this.logger.info("meta", ctx.meta);
		},
		getUserInfo(this: Service, ctx: Context<any, any>) {
			return ctx.meta.user;
		},
		list(this: Service, ctx: Context<any, any>): any {
			return ctx.meta.$rooms;
		},
		join(this: Service, ctx: any): any {
			ctx.options.parentCtx.meta.$join = ctx.params.room;
		},

		async add(this: Service, ctx: Context<any, any>): Promise<any> {
			this.logger.info("meta", ctx.meta);
			const rooms = ["room2", "room3"];
			await this.broker.call("notif.broadcast", {
				event: "notifyGPS",
				// namespace: "/",
				// rooms,
				args: [
					`Hello from ${ctx.meta.$socketId} - from room: ${JSON.stringify(
						ctx.meta.$rooms,
						null,
						2,
					)} - to room: ${JSON.stringify(rooms, null, 2)}`,
				],
			});
			return Number(ctx.params.a) + Number(ctx.params.b);
		},
	},
};

export default MathService;
