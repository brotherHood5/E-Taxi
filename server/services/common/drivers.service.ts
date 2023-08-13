import type { ActionParams, Context } from "moleculer";
import { Config } from "../../common";
import { DriverStatus, VehicleType } from "../../entities";
import { createTestDrivers } from "../../helpers/seed";
import { AuthMixin, DbMixin } from "../../mixins";
import type {
	ActionCreateParams,
	DriversServiceSchema,
	DriversThis,
} from "../../types/common/driver";
import { UserRole } from "../../types/common/user";

const phoneNumberRegex = /^0[0-9]{9}$/;

const validateDriverBase: ActionParams = {
	phoneNumber: {
		type: "string",
		min: 10,
		max: 10,
		pattern: phoneNumberRegex,
		singleLine: true,
		trim: true,
	},
	phoneNumberVerified: { type: "boolean", optional: true },
	enable: { type: "boolean", optional: true },
	active: { type: "boolean", optional: true },
	roles: {
		type: "array",
		items: "string",
		enum: Object.values(UserRole),
		optional: true,
	},
	driverStatus: {
		type: "array",
		items: "string",
		enum: Object.values(DriverStatus),
		optional: true,
	},
	vehicleType: {
		type: "array",
		items: "string",
		enum: Object.values(VehicleType),
		optional: true,
	},
};

const DriversService: DriversServiceSchema = {
	name: "drivers",
	authToken: Config.DRIVERS_AUTH_TOKEN,
	mixins: [DbMixin("drivers"), AuthMixin],

	settings: {
		// Available fields in the responses
		fields: [
			"_id",
			"fullName",
			"phoneNumber",
			"phoneNumberVerified",
			"driverStatus",
			"vehicleType",
			"enable",
			"active",
			"roles",
			"createdAt",
			"updatedAt",
		],

		// Validator for the `create` & `insert` actions.
		entityValidator: {
			fullName: { type: "string", min: 3, max: 255, optional: true },
			phoneNumber: {
				type: "string",
				min: 10,
				max: 10,
				pattern: phoneNumberRegex,
				singleLine: true,
				trim: true,
			},
			phoneNumberVerified: { type: "boolean", optional: true },
			enable: { type: "boolean", optional: true },
			active: { type: "boolean", optional: true },
			createdAt: { type: "date", optional: true },
			updatedAt: { type: "date", optional: true },
			roles: {
				type: "array",
				items: "string",
				enum: Object.values(UserRole),
				optional: true,
			},
			driverStatus: {
				type: "array",
				items: "string",
				enum: Object.values(DriverStatus),
				optional: true,
			},
			vehicleType: {
				type: "array",
				items: "string",
				enum: Object.values(VehicleType),
				optional: true,
			},
		},

		indexes: [{ phoneNumber: 1 }],

		accessTokenSecret: Config.ACCESS_TOKEN_SECRET || "test",
		accessTokenExpiry: Config.ACCESS_TOKEN_EXPIRY || "30m",

		refreshTokenExpiry: Config.REFRESH_TOKEN_EXPIRY || 24 * 60 * 60 * 7,
		otpExpireMin: Config.OTP_EXPIRE_MIN || 1,
	},

	actions: {
		create: {
			restricted: ["api"],
			params: {
				...validateDriverBase,
				passwordHash: { type: "string" },
			},
			async handler(this: DriversThis, ctx: Context<ActionCreateParams>) {
				ctx.params.roles = [UserRole.DRIVER];
				const entity = await this._create(ctx, ctx.params);
				return entity;
			},
		},
		list: {
			restricted: ["api"],
			cache: {
				ttl: 60 * 2, // 2min
			},
		},
		get: {
			restricted: ["api"],
		},
		update: {
			restricted: ["api"],
		},
		remove: {
			restricted: ["api"],
		},
		find: {
			restricted: ["api"],
		},
	},

	methods: {
		async seedDB(this: DriversThis) {
			const drivers = createTestDrivers(10);
			await this.adapter.insertMany(drivers);
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
};

export default DriversService;
