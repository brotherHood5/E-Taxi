import type { Service, ServiceSchema } from "moleculer";
import { Config } from "../../../common";
import { AMQPMixin, DbMixin } from "../../../mixins";

const BookingService: ServiceSchema = {
	name: "bookingSystem",
	authToken: Config.BOOKING_AUTH_TOKEN,
	mixins: [DbMixin("bookings"), AMQPMixin],
	settings: {
		fields: [
			"_id",
			"name",
			"phoneNumber",
			"formattedAddress",
			"status",
			"createdAt",
			"updatedAt",
		],
		entityValidator: {},
	},

	actions: {
		book: {
			rest: "GET /book",
			handler(this: Service, ctx: any): any {
				const data = {
					address: "123 Main St",
					name: "John Doe",
				};
				this.sendAddressToCoordSystem(data);
				return { ...data };
			},
		},
	},
	methods: {
		sendAddressToCoordSystem(this: Service, data: any): void {
			this.addAMQPJob("coord.system.receiveAddress", data);
		},
	},
};

export default BookingService;
