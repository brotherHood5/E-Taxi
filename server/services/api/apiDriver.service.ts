import cookieParser from "cookie-parser";
import type { Context } from "moleculer";
import ApiGateway from "moleculer-web";
import type { IncomingRequest, Route } from "moleculer-web";
import { Config } from "../../common";
import { ApiAuthMixin } from "../../mixins";
import type { ApiGatewayMeta } from "../../types/common";

const ApiDriverService = {
	name: "apiDriver",
	authToken: Config.API_AUTH_TOKEN,
	mixins: [ApiGateway, ApiAuthMixin("drivers")],

	// More info about settings: https://moleculer.services/docs/0.14/moleculer-web.html
	settings: {
		port: Config.DRIVER_PORT,

		ip: Config.HOST || "0.0.0.0",

		// Global Express middlewares. More info: https://moleculer.services/docs/0.14/moleculer-web.html#Middlewares
		use: [cookieParser()],

		cors: {
			// Configures the Access-Control-Allow-Origin CORS header.
			origin: "*",
			// Configures the Access-Control-Allow-Methods CORS header.
			methods: ["GET", "OPTIONS", "POST", "PUT", "DELETE"],
			// Configures the Access-Control-Allow-Headers CORS header.
			allowedHeaders: [],
			// Configures the Access-Control-Expose-Headers CORS header.
			exposedHeaders: [],
			// Configures the Access-Control-Allow-Credentials CORS header.
			credentials: false,
			// Configures the Access-Control-Max-Age CORS header.
			maxAge: 3600,
		},

		routes: [
			{
				path: "/api/v1",

				whitelist: ["drivers.*", "$node.*", "apiDriver.*"],

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

				mappingPolicy: "all", // Available values: "all", "restrict"

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
};

export default ApiDriverService;
