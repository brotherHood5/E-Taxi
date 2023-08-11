import type { ActionParams, Context } from "moleculer";
import { Config } from "../../../common";
import { createTestCustomers } from "../../../helpers/seed";
import { AuthMixin, DbMixin } from "../../../mixins";
import type {
	ActionCreateParams,
	CustomersServiceSchema,
	CustomersThis,
} from "../../../types/common/customer";
import type { UserAuthMeta } from "../../../types/common/user";
import { UserRole } from "../../../types/common/user";

const phoneNumberRegex = /^0[0-9]{9}$/;

const validateCustomerBase: ActionParams = {
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
};

const CustomersService: CustomersServiceSchema = {
	name: "customers",
	authToken: Config.CUSTOMERS_AUTH_TOKEN,
	mixins: [DbMixin("customers"), AuthMixin],

	settings: {
		// Available fields in the responses
		fields: [
			"_id",
			"fullName",
			"phoneNumber",
			"phoneNumberVerified",
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
			auth: true,
			// roles: [UserRole.ADMIN],
			params: {
				...validateCustomerBase,
				passwordHash: { type: "string" },
			},
			async handler(this: CustomersThis, ctx: Context<ActionCreateParams>) {
				ctx.params.roles = [UserRole.CUSTOMER];
				const entity = await this._create(ctx, ctx.params);
				return entity;
			},
		},
		list: {
			restricted: ["api"],
			auth: true,
			// roles: [UserRole.ADMIN],
			cache: {
				ttl: 60 * 2, // 2min
			},
		},
		get: {
			restricted: ["api"],
			auth: true,
			// roles: [UserRole.ADMIN],
		},

		update: {
			restricted: ["api"],
			auth: true,
		},
		remove: {
			restricted: ["api"],
			auth: true,
			// roles: [UserRole.ADMIN],
		},

		find: {
			restricted: ["api", "bookingSystem"],
			auth: true,
			roles: [UserRole.ADMIN, UserRole.STAFF],
			cache: false,
		},

		me: {
			restricted: ["api"],
			rest: "GET /me",
			auth: true,
			roles: [UserRole.CUSTOMER],
			async handler(this: CustomersThis, ctx: Context<any, UserAuthMeta>) {
				const entity = await this._get(ctx, { id: ctx.meta.user._id });
				return this.transformDocuments(ctx, {}, entity);
			},
		},
	},

	methods: {
		async seedDB(this: CustomersThis) {
			const customers = createTestCustomers(10);
			await this.adapter.insertMany(customers);
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

export default CustomersService;
