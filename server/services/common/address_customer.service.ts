import type { Service, ServiceSchema } from "moleculer";
import { DbMixin } from "../../mixins";
import { MongoObjectId } from "../../types";

const AddressCustomerService: ServiceSchema = {
	name: "address_customer",
	mixins: [DbMixin("address_customer")],
	settings: {
		rest: "",
		fields: ["_id", "phoneNumber", "addressId", "address", "count"],

		populates: {
			address: {
				field: "addressId",
				action: "address.get",
				params: {
					fields: "_id homeNo street ward district city lat lon",
				},
			},
		},

		entityValidator: {
			phoneNumber: "string",
			addressId: {
				type: "objectID",
				ObjectID: MongoObjectId,
			},
			count: { type: "number", optional: true },
		},
	},

	actions: {
		find: {
			cache: {
				ttl: 60,
			},
		},

		get: {
			cache: {
				ttl: 60,
			},
		},

		getTop5Address: {
			params: {
				phoneNumber: "string",
			},
			cache: {
				keys: ["phoneNumber"],
				ttl: 60,
			},
			async handler(this: Service, ctx: any) {
				const result = await this.actions.find({
					query: { phoneNumber: ctx.params.phoneNumber },
					populate: ["address"],
					sort: "-count",
					limit: 5,
				});
				return result;
			},
		},

		increaseCount: {
			params: {
				phoneNumber: "string",
				addressId: "string",
				value: "number",
			},
			async handler(this: Service, ctx: any) {
				const result = await this.adapter.find({
					query: {
						phoneNumber: ctx.params.phoneNumber,
						addressId: new MongoObjectId(ctx.params.addressId),
					},
				});

				if (result.length === 0) {
					return null;
				}

				const doc = await this.adapter.updateById(result[0]._id, {
					$inc: { count: ctx.params.value },
				});

				const json = await this.transformDocuments(ctx, ctx.params, doc);
				await this.entityChanged("updated", json, ctx);
				return json;
			},
		},
	},

	beforeEntityCreate(entity: any) {
		entity.addressId = new MongoObjectId(entity.addressId);
		return entity;
	},

	beforeEntityUpdate(entity: any) {
		entity.addressId = new MongoObjectId(entity.addressId);
		return entity;
	},
};

export default AddressCustomerService;
