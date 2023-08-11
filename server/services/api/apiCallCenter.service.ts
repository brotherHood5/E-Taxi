import cookieParser from "cookie-parser";
import type { Context } from "moleculer";
import type { IncomingRequest, Route } from "moleculer-web";
import ApiGateway from "moleculer-web";
import { Config } from "../../common";
import { ApiAuthMixin } from "../../mixins";
import type { ApiGatewayMeta } from "../../types";

const ApiCallCenterService = {
	name: "apiCallCenter",
	authToken: Config.API_AUTH_TOKEN,
	mixins: [ApiGateway, ApiAuthMixin("staffs")],

	settings: {
		port: Config.CALLCENTER_PORT,

		ip: Config.HOST || "0.0.0.0",

		use: [cookieParser()],

		routes: [
			{
				path: "/api/v1",
				cors: {
					origin: ["*"],
					methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
					credentials: false,
					maxAge: 3600,
				},

				whitelist: [
					"geo.*",
					"$node.*",
					"callcenter.*",
					"apiCallCenter.*",
					"staffs.*",
					"bookingSystem.*",
					"coordSystem.*",
					"monitorSystem.*",
				],

				aliases: {
					"GET /coord-system/sse": {
						action: "coord.system.sse",
						passReqResToParams: true,
					},
				},

				mergeParams: true,

				authentication: true,

				authorization: true,

				autoAliases: true,

				bodyParsers: {
					json: {
						strict: false,
						limit: "1MB",
					},
					urlencoded: {
						extended: true,
						limit: "1MB",
					},
				},

				mappingPolicy: Config.MAPPING_POLICY || "all",

				// Enable/disable logging
				logging: true,

				onBeforeCall(
					ctx: Context<any, ApiGatewayMeta>,
					route: Route,
					req: IncomingRequest,
				): void {
					ctx.meta.$requestHeaders = req.headers;
				},
			},
		],

		// Do not log client side errors (does not log an error response when the error.code is 400<=X<500)
		log4XXResponses: false,
		// Logging the request parameters. Set to any log level to enable it. E.g. "info"
		logRequestParams: "info",
		// Logging the response data. Set to any log level to enable it. E.g. "info"
		logResponseData: null,

		// Serve assets from "public" folder. More info: https://moleculer.services/docs/0.14/moleculer-web.html#Serve-static-files
		assets: {
			folder: "public",

			// Options to `server-static` module
			options: {},
		},
	},
	actions: {},
	methods: {},
};

export default ApiCallCenterService;
