import { Config } from "../../common";
import { createTestAddresses } from "../../helpers/seed";
import { DbMixin } from "../../mixins";
import type { AddresssServiceSchema } from "../../types/common/address";

const AddressService: AddresssServiceSchema = {
	name: "address",
	authToken: Config.ADDRESS_AUTH_TOKEN,
	mixins: [DbMixin("address")],

	settings: {
		rest: "",
		fields: [
			"_id",
			"homeNo",
			"street",
			"ward",
			"district",
			"city",
			"lat",
			"lon",
			"createdAt",
			"updatedAt",
		],

		entityValidator: {
			homeNo: "string|optional",
			street: "string|optional",
			ward: "string|optional",
			district: "string|optional",
			city: "string|optional",
			lat: "number|optional",
			lon: "number|optional",
			count: { type: "number", optional: true },
			createdAt: "date|optional",
			updatedAt: "date|optional",
		},
	},

	actions: {
		get: {
			cache: false,
		},
	},

	methods: {
		async seedDB(this) {
			const customers = createTestAddresses(10);
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

export default AddressService;
