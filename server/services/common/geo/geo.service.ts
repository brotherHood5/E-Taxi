import type { Context, Service, ServiceSettingSchema } from "moleculer";
import type { Entry, Options, Query } from "node-geocoder";
import NodeGeocoder from "node-geocoder";
import { Config } from "../../../common";
import type { GuardServiceSchema } from "../../../types/common";

export type GeoSettings = ServiceSettingSchema;

export type GeoServiceSchema = GuardServiceSchema<GeoSettings> & { methods: GeoMethods };

export type GeoThis = Service<GeoSettings>;

interface GeoMethods {
	geocode: (params: string | Query, cb?: (err: any, data: Entry[]) => void) => Promise<Entry[]>;
	reverse: (loc: Location, cb?: (err: any, data: Entry[]) => void) => Promise<Entry[]>;
}

interface OpenStreetMapQuery {
	street?: string;
	city?: "string";
	state?: "string";
	county?: "string";
	country?: string;
	postalcode?: "string";
}

interface GeoCodeParams {
	q: string | OpenStreetMapQuery;
}

interface GeoCodeReverseParams {
	lat: number;
	lon: number;
}

const GeoService: GeoServiceSchema = {
	name: "geo",
	authToken: Config.GEO_AUTH_TOKEN,
	settings: {
		geoProvider: "openstreetmap",
	},

	actions: {
		geocode: {
			restricted: ["api"],
			rest: "GET /geocode",
			params: {
				q: [
					{ type: "string" },
					{
						type: "object",
						props: {
							street: { type: "string", optional: true },
							city: { type: "string", optional: true },
							county: { type: "string", optional: true },
							state: { type: "string", optional: true },
							country: { type: "string", optional: true, default: "VN" },
							postalcode: { type: "string", optional: true },
						},
					},
				],
			},
			cache: {
				keys: ["q"],
			},
			async handler(this: GeoThis, ctx: Context<GeoCodeParams>) {
				const result = await this.geocode(ctx.params.q);
				return result;
			},
		},
		reverse: {
			restricted: ["api"],
			rest: "GET /reverse",
			params: {
				lat: { type: "number" },
				lon: { type: "number" },
			},
			cache: {
				keys: ["lat", "lon"],
			},
			async handler(this: GeoThis, ctx: Context<GeoCodeReverseParams>) {
				const result = await this.reverse(ctx.params);
				return result;
			},
		},
	},

	methods: {
		geocode(this: GeoThis, params: string | Query, cb?: (err: any, data: Entry[]) => void) {
			return this.geocoder.geocode(params, cb);
		},
		reverse(this: GeoThis, loc: Location, cb?: (err: any, data: Entry[]) => void) {
			return this.geocoder.reverse(loc, cb);
		},
	},

	started(this: GeoThis) {
		let option: Options;
		if (this.settings.geoProvider === "openstreetmap") {
			option = {
				provider: "openstreetmap",
			};
		} else {
			option = {
				provider: "locationiq",
				apiKey: process.env.LOCATIONIQ_API_KEY,
			};
		}

		this.teleportGeocoder = NodeGeocoder({
			provider: "teleport",
		});
		this.geocoder = NodeGeocoder(option);
	},
};

export default GeoService;
