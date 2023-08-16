import type { Service, ServiceSchema } from "moleculer";
import { Config } from "../../common";
import type { IBooking } from "../../entities";
import { BookingStatus } from "../../entities";
import { AMQPMixin, DbMixin } from "../../mixins";
import { MongoObjectId } from "../../types";

const BookingService: ServiceSchema = {
	name: "bookingSystem",
	authToken: Config.BOOKING_AUTH_TOKEN,
	mixins: [DbMixin("bookings"), AMQPMixin],
	settings: {
		rest: "/booking-system",
		fields: [
			"_id",
			"phoneNumber",
			"driver",
			"vehicleType",
			"pickupAddr",
			"destAddr",
			"status",
			"count",
			"createdAt",
			"updatedAt",
		],
		populates: {
			pickupAddr: {
				action: "address.get",
				params: {
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
				},
			},
			destAddr: {
				action: "address.get",
				params: {
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
				},
			},
		},
		entityValidator: {},
	},

	AMQPQueues: {
		"bookingSystem.booking_process": {
			handler(this: Service, channel: any, msg: any): void {
				const req = JSON.parse(msg.content.toString());
				this.addAMQPJob("monitorSystem.listen_event", {
					id: req._id,
					status: BookingStatus.PROCESSING,
				});
				channel.ack(msg);
			},
		},

		"bookingSystem.booking_req": {
			handler(this: Service, channel: any, msg: any): void {
				const req = JSON.parse(msg.content.toString()) as IBooking;
				// Add to monitor
				this.addAMQPJob("monitorSystem.booking_monitor", req);

				if (
					!req.pickupAddr.lat ||
					!req.pickupAddr.lon ||
					!req.destAddr.lat ||
					!req.destAddr.lon
				) {
					this.addAMQPJob("coordSystem.address_resolve", req);
				} else {
					this.addAMQPJob("bookingSystem.booking_process", req);
				}
				channel.ack(msg);
			},
			channel: {
				assert: {
					durable: true,
				},
				prefetch: 1,
			},
			consume: {
				noAck: false,
			},
		},
	},

	actions: {
		book: {
			rest: "POST /book",
			handler(this: Service, ctx: any) {
				// const { phoneNumber, carType, pickupAddr, destAddr } = ctx.params;
				const { a } = ctx.params;
				const coord = {
					lat: 21.027763,
					lon: 105.83416,
				};
				const data: IBooking = {
					_id: new MongoObjectId(),
					phoneNumber: "0972360214",
					vehicleType: "4-seat",
					pickupAddr: {
						homeNo: "123",
						street: "Nguyen Van Cu",
						ward: "Long Bien",
						district: "Long Bien",
						city: "Ha Noi",
					},
					destAddr: {
						homeNo: "123",
						street: "Nguyen Van Cu",
						ward: "Long Bien",
						district: "Long Bien",
						city: "Ha Noi",
					},
					status: BookingStatus.NEW,
					createdAt: new Date(),
					updatedAt: new Date(),
				};
				if (a === 1) {
					data.pickupAddr = {
						...data.pickupAddr,
						...coord,
					};
					data.destAddr = {
						...data.destAddr,
						...coord,
					};
				}

				const job = this.addAMQPJob("bookingSystem.booking_req", data);
			},
		},

		bookReq: {
			rest: "POST /request",
			params: {
				phoneNumber: "string",
				carType: "string",
				pickupAddr: "object",
				destAddr: "object",
			},
			async handler(this: Service, ctx: any) {
				const { phoneNumber, carType, pickupAddr, destAddr } = ctx.params;
				this.logger.info("bookReq", ctx.params);
				const customer = await ctx.call("customers.find", {
					query: { phoneNumber: "0972360214" },
				});
				const pickupAddrId = await ctx.call("address.create", pickupAddr);
				const destAddrId = await ctx.call("address.create", destAddr);
				const data = await this.adapter.insert({
					phoneNumber,
					carType,
					pickupAddr: pickupAddrId,
					destAddr: destAddrId,
					count: 0,
				});
				return data;
				// this.sendAddressToCoordSystem(data);
			},
		},

		getBookingHistory: {
			rest: "GET /history",
			params: {
				phoneNumber: "string",
			},
			async handler(this: Service, ctx: any): Promise<any> {
				const { phoneNumber } = ctx.params;
				const data = await this.adapter.find({
					query: { phoneNumber },
					sort: "updatedAt",
				});
				return data;
			},
		},

		getTop5Booking: {
			rest: "GET /top-booking",
			params: {
				phoneNumber: "string",
			},
			async handler(this: Service, ctx: any): Promise<any> {
				const { phoneNumber } = ctx.params;
				const data = await this.adapter.find({
					query: { phoneNumber },
					sort: "count",
					limit: 5,
				});
				return data;
			},
		},
	},
	methods: {},
};

export default BookingService;
