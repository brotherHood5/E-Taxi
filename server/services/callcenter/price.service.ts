import { DbMixin } from "mixins";
import type { Service, ServiceSchema } from "moleculer";
import { VehicleType } from "../../entities";

const PriceService: ServiceSchema = {
	name: "price",
	mixins: [DbMixin("price_table")],
	settings: {
		fields: ["_id", "first2kmPrice", "nextPerKmPrice", "vehicleType"],
		indexes: [{ vehicleType: 1, unique: true }],
	},
	actions: {
		calculatePrice: {
			rest: "GET /calculate-price",
			params: {
				distance: "number",
				vehicleType: ["string", "number"],
			},
			async handler(ctx) {
				const { distance, vehicleType } = ctx.params;
				const priceTable = await this.adapter.find({
					query: { vehicleType: vehicleType.toString() },
				});
				if (Number(distance) <= 2) {
					return Number(priceTable[0].first2kmPrice);
				}
				return (
					Number(priceTable[0].first2kmPrice) +
					(distance - 2) * Number(priceTable[0].nextPerKmPrice)
				);
			},
		},

		find: {
			cache: false,
		},
	},
	methods: {
		async seedDB(this: Service) {
			const priceTable = [
				{
					first2kmPrice: 12500,
					nextPerKmPrice: 4300,
					vehicleType: VehicleType.TWO_SEATS,
				},
				{
					first2kmPrice: 29000,
					nextPerKmPrice: 10000,
					vehicleType: VehicleType.FOUR_SEATS,
				},
				{
					first2kmPrice: 34000,
					nextPerKmPrice: 13000,
					vehicleType: VehicleType.SEVEN_SEATS,
				},
			];
			await this.adapter.insertMany(priceTable);
		},
	},
	events: {},
	created() {},
	started() {},
	stopped() {},
};

export default PriceService;
