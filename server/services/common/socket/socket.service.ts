import type { Context, Service } from "moleculer";
import SocketIOService from "moleculer-io";
import ApiGateway from "moleculer-web";
import { Config } from "../../../common";
import type {
	AuthResolveTokenParams,
	IUserBase,
	NotifServiceSchema,
	NotifThis,
} from "../../../types";
import { SmsSendParamsValidator } from "../../../types/common";

const ApiGatewayErrors = ApiGateway.Errors;

const SocketService: NotifServiceSchema = {
	name: "socket",
	authToken: Config.NOTIF_AUTH_TOKEN,
	mixins: [SocketIOService as any],

	settings: {
		port: Config.SOCKET_PORT,
		cors: {
			origin: ["*"],
			methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
			allowedHeaders: [],
			exposedHeaders: [],
			credentials: false,
			maxAge: 3600,
		},
		logRequest: "info",
		logRequestParams: "info",
		logClientConnection: "info",
		logResponse: "info",

		// Socket IO settings
		io: {
			namespaces: {
				"/coord-system": {
					authorization: true,
					events: {
						call: {
							whitelist: ["**"],
							onBeforeCall: (
								ctx: any,
								socket: any,
								action: any,
								params: any,
								opts: any,
							): any => {
								ctx.meta = opts.meta;
							},
							onAfterCall: (ctx: any, socket: any, res: any): any => {},
						},

						async disconnect(data, ack) {
							// eslint-disable-next-line @typescript-eslint/no-this-alias
							const socket = this;
							await socket.$service.broker.call("coordSystem.disconnect", socket.id);
						},
					},
				},

				"/monitor": {
					authorization: false,
					events: {
						call: {
							whitelist: ["monitorSystem.*"],
						},
					},
				},

				"/drivers": {
					authorization: true,
					events: {
						call: {
							whitelist: ["**"],
							onBeforeCall: (
								ctx: any,
								socket: any,
								action: any,
								params: any,
								opts: any,
							): any => {
								ctx.meta = opts.meta;
							},
							onAfterCall: (ctx: any, socket: any, res: any): any => {},
						},
					},
				},

				"/customers": {
					authorization: true,
					events: {
						call: {
							whitelist: ["**"],
							onBeforeCall: (
								ctx: any,
								socket: any,
								action: any,
								params: any,
								opts: any,
							): any => {
								ctx.meta = opts.meta;
							},
							onAfterCall: (ctx: any, socket: any, res: any): any => {},
						},
					},
				},
			},
		},
	},

	actions: {
		join: {
			params: {
				room: "string",
			},
			handler(ctx: Context<any, any>): void {
				ctx.meta.$join = ctx.params.room;
				if (ctx.options.parentCtx) {
					ctx.options.parentCtx.meta = ctx.meta;
				}
			},
		},

		leave: {
			params: {
				room: "string",
			},
			handler(ctx: Context<any, any>): void {
				ctx.meta.$leave = ctx.params.room;
				if (ctx.options.parentCtx) {
					ctx.options.parentCtx.meta = ctx.meta;
				}
			},
		},

		getClientsInRoom: {
			params: {
				room: "string",
			},
			handler(ctx: Context<any, any>): string[] | [] | undefined {
				return ctx.meta.$rooms;
			},
		},

		notify: {
			params: {
				provider: "string",
				data: [
					{
						type: "object",
						props: {
							...SmsSendParamsValidator,
						},
					},
					{
						type: "object",
						props: {
							event: { type: "string" },
							namespace: { type: "string", optional: true },
							args: { type: "array", optional: true },
							volatile: { type: "boolean", optional: true },
							local: { type: "boolean", optional: true },
							rooms: { type: "array", items: "string", optional: true },
						},
					},
				],
			},

			async handler(this: NotifThis, ctx: Context<any, any>): Promise<any> {
				const { provider, data } = ctx.params;
				this.logger.info("notify", provider, data);

				if (provider === "sms") {
					const result = await ctx.call("sms.send", data, {
						parentCtx: ctx,
					});
					return result;
				}

				if (provider === "app") {
					const result = await this.actions.broadcast(data, {
						meta: ctx.meta,
						parentCtx: ctx,
					});
					return result;
				}

				return Promise.reject(
					new ApiGatewayErrors.BadRequestError("INVALID_PROVIDER", null),
				);
			},
		},
	},

	methods: {
		async socketAuthorize(socket: any) {
			this.logger.info("Login using token:", socket.handshake.auth.token);
			const accessToken = socket.handshake.auth.token;
			const { refreshToken } = socket.handshake.auth;
			const { service } = socket.handshake.query;

			if (!service) {
				return Promise.reject(
					new ApiGatewayErrors.UnAuthorizedError("NO_PROVIDER_SERVICE", null),
				);
			}

			if (accessToken) {
				try {
					const user = await this.broker.call<
						IUserBase | undefined,
						AuthResolveTokenParams
					>(`${service}.resolveToken`, { token: accessToken });
					if (user) {
						return await Promise.resolve(user);
					}
				} catch (error) {
					return Promise.reject(
						new ApiGatewayErrors.UnAuthorizedError(
							ApiGatewayErrors.ERR_INVALID_TOKEN,
							null,
						),
					);
				}
			}

			// No token.
			return Promise.reject(
				new ApiGatewayErrors.UnAuthorizedError(ApiGatewayErrors.ERR_NO_TOKEN, null),
			);
		},

		socketSaveMeta(socket, ctx) {
			this.socketSaveUser(socket, ctx.meta.user);
		},

		socketGetMeta(socket) {
			const meta = {
				$socketId: socket.id,
				user: socket.client.user,
				$rooms: Array.from(socket.rooms.keys()),
			};
			return meta;
		},
	},
};

export default SocketService;
