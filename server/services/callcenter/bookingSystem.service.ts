import type { Service, ServiceSchema } from "moleculer";
import { Config } from "../../common";
import type { AddressEntity, IAddress, IBooking } from "../../entities";
import { BookingStatus } from "../../entities";
import { AMQPMixin, DbMixin } from "../../mixins";
import type { ObjectId } from "../../types";
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
			"driverId",
			"driver",
			"vehicleType",
			"pickupAddr",
			"destAddr",
			"status",
			"createdAt",
			"updatedAt",
		],

		populates: {
			pickupAddr: {
				action: "address.get",
				params: {
					fields: "_id homeNo street ward district city lat lon",
				},
			},
			destAddr: {
				action: "address.get",
				params: {
					fields: "_id homeNo street ward district city lat lon",
				},
			},
			driver: {
				field: "driverId",
				action: "driver.get",
				params: {
					fields: "_id fullName phoneNumber vehicleType",
				},
			},
		},

		entityValidator: {
			phoneNumber: "string",
			vehicleType: "string",
			pickupAddr: {
				type: "objectID",
				ObjectID: MongoObjectId,
			},
			destAddr: {
				type: "objectID",
				ObjectID: MongoObjectId,
			},
			status: "string",
			createdAt: "date|optional",
			updatedAt: "date|optional",
		},
	},

	AMQPQueues: {
		"bookingSystem.booking_process": {
			async handler(this: Service, channel: any, msg: any): Promise<void> {
				const req = JSON.parse(msg.content.toString());
				try {
					if (req.status === BookingStatus.COORDINATING) {
						// Cap nhat dia chi da phan giai vo db tuong duong cai dat xe do
						await this.actions.updateBookingAddress({
							id: req._id,
							pickupAddr: req.pickupAddr,
							destAddr: req.destAddr,
						});
					}

					req.status = BookingStatus.PROCESSING;
					await this.actions.updateBookingStatus({
						id: req._id,
						status: req.status,
					});

					// TODO: Find Driver

					this.addAMQPJob("monitorSystem.listen_event", {
						id: req._id,
						status: req.status,
					});
					channel.ack(msg);
				} catch (error) {
					channel.nack(msg);
				}
			},
		},

		"bookingSystem.booking_req": {
			handler(this: Service, channel: any, msg: any): void {
				const req = JSON.parse(msg.content.toString()) as IBooking;
				// Theo doi moi
				this.addAMQPJob("monitorSystem.booking_monitor", req);

				req.pickupAddr = req.pickupAddr as AddressEntity;
				req.destAddr = req.destAddr as AddressEntity;
				if (
					!req.pickupAddr.lat ||
					!req.pickupAddr.lon ||
					!req.destAddr.lat ||
					!req.destAddr.lon
				) {
					// Chuyen qua phan giai dia chi
					this.addAMQPJob("coordSystem.address_resolve", req);
				} else {
					// Xu li dat xe
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
		debug: {
			async handler(this: Service, ctx: any) {
				const { phoneNumber, vehicleType, pickupAddr, destAddr } = ctx.params;
				const coord = {
					lat: 21.027763,
					lon: 105.83416,
				};

				const id1 = "64dcbfa928d2047859049e68";
				const id2 = "64dcd2fd32d8cf1144801d57";

				const data: IBooking = {
					// _id: new MongoObjectId("64dcba3c94b438a1b79c4ba0"),
					phoneNumber: "0972360214",
					vehicleType: "2-seat",
					pickupAddr: {
						homeNo: "123",
						street: "Binh Chieu",
						ward: "BinhChieu",
						district: "Thu Duc",
						city: "Ho Chi Minh",
					},
					destAddr: {
						homeNo: "123",
						street: "Nguyen Van Cu",
						ward: "Long Bien",
						district: "Long Bien",
						city: "Ha Noi",
					},
					// pickupAddr: id1,
					// destAddr: id2,
					status: BookingStatus.NEW,
				};

				const result = await this.createNew(data);
				this.addAMQPJob("bookingSystem.booking_req", result);
				return result;

				// const { a } = ctx.params;
				// const coord = {
				// 	lat: 21.027763,
				// 	lon: 105.83416,
				// };

				// const data: IBooking = {
				// 	_id: new MongoObjectId(),
				// 	phoneNumber: "0972360214",
				// 	vehicleType: "4-seat",
				// 	pickupAddr: {
				// 		homeNo: "123",
				// 		street: "Binh Chieu",
				// 		ward: "BinhChieu",
				// 		district: "Thu Duc",
				// 		city: "Ho Chi Minh",
				// 	},
				// 	destAddr: {
				// 		homeNo: "123",
				// 		street: "Nguyen Van Cu",
				// 		ward: "Long Bien",
				// 		district: "Long Bien",
				// 		city: "Ha Noi",
				// 	},
				// 	status: BookingStatus.NEW,
				// 	createdAt: new Date(),
				// 	updatedAt: new Date(),
				// };
				// if (a === 1) {
				// 	data.pickupAddr = {
				// 		...(data.pickupAddr as IAddress),
				// 		...coord,
				// 	};
				// 	data.destAddr = {
				// 		...(data.destAddr as IAddress),
				// 		...coord,
				// 	};
				// }

				// const job = this.addAMQPJob("bookingSystem.booking_req", data);
				// return data;
			},
		},

		bookThroughApp: {
			params: {
				phoneNumber: "string",
				vehicleType: "string",
				pickupAddr: "object", // Dia chi nay da co lat lon ko can phan giai
				destAddr: "object", // Dia chi nay da co lat lon ko can phan giai
			},
			handler(this: Service, ctx: any) {
				const req = ctx.params;
				this.addAMQPJob("bookingSystem.booking_req", req);
				return true;
			},
		},

		// Done
		// -----------------------------
		bookThroughCallCenter: {
			rest: "POST /book",
			params: {
				phoneNumber: "string",
				vehicleType: "string",
				pickupAddr: [{ type: "object" }, { type: "string" }],
				destAddr: [{ type: "object" }, { type: "string" }],
			},
			async handler(this: Service, ctx: any) {
				const { phoneNumber, vehicleType, pickupAddr, destAddr } = ctx.params;
				const data: IBooking = {
					phoneNumber,
					vehicleType,
					pickupAddr,
					destAddr,
					status: BookingStatus.NEW,
				};

				const result = await this.createNew(data);
				this.addAMQPJob("bookingSystem.booking_req", result);
				return result;
			},
		},

		updateBookingAddress: {
			params: {
				id: "string",
				pickupAddr: "object",
				destAddr: "object",
			},
			async handler(this: Service, ctx: any) {
				const { id, pickupAddr, destAddr } = ctx.params;
				const result = await this.actions.find({
					query: { _id: new MongoObjectId(id) },
				});

				if (result.length === 0) {
					throw new Error("Booking not found");
				}

				if (pickupAddr) {
					await this.broker.call("address.update", {
						id: result[0].pickupAddr,
						...pickupAddr,
					});
				}

				if (destAddr) {
					await this.broker.call("address.update", {
						id: result[0].destAddr,
						...destAddr,
					});
				}

				return true;
			},
		},

		updateBookingStatus: {
			params: {
				id: "string",
				status: "string",
			},
			async handler(this: Service, ctx: any) {
				const { id, status } = ctx.params;
				const result = await this.actions.update({
					id,
					status,
				});
				return result;
			},
		},

		getBookingHistory: {
			rest: "GET /history",
			params: {
				phoneNumber: "string",
			},
			async handler(this: Service, ctx: any): Promise<any> {
				const { phoneNumber } = ctx.params;
				const data = await this.actions.find({
					query: { phoneNumber },
					populate: ["pickupAddr", "destAddr"],
					sort: "-updatedAt",
				});
				return data;
			},
		},

		getTop5Address: {
			rest: "GET /top-address",
			params: {
				phoneNumber: "string",
			},
			async handler(this: Service, ctx: any): Promise<any> {
				const { phoneNumber } = ctx.params;
				const data = await this.broker.call("address_customer.getTop5Address", {
					phoneNumber,
				});
				return data;
			},
		},

		get: {
			cache: false,
		},

		find: {
			cache: false,
		},
		// -----------------------------
	},
	methods: {
		async createNew(this: Service, data: IBooking) {
			const entity = {
				...data,
			};

			const tasks = [
				new Promise((resolve, reject) => {
					if (typeof data.pickupAddr === "object") {
						this.createNewAddress(data.pickupAddr).then((pickupAddr: IAddress) => {
							entity.pickupAddr = pickupAddr._id as ObjectId;
							resolve(true);
						});
					} else {
						reject();
					}
				}),
				new Promise((resolve, reject) => {
					if (typeof data.destAddr === "object") {
						this.createNewAddress(data.destAddr).then((destAddr: IAddress) => {
							entity.destAddr = destAddr._id as ObjectId;
							this.broker
								.call("address_customer.create", {
									phoneNumber: entity.phoneNumber,
									addressId: destAddr._id,
									count: -1,
								})
								.then(resolve)
								.catch(reject);
						});
					} else {
						reject();
					}
				}),
			];

			// Create new address
			await Promise.allSettled(tasks);
			await this.broker.call("address_customer.increaseCount", {
				phoneNumber: entity.phoneNumber,
				addressId: entity.destAddr,
				value: 1,
			});

			const result = await this.actions.create(entity).then((res) => {
				this.logger.warn(res);
				return this.actions.get({
					id: res._id?.toString(),
					populate: ["pickupAddr", "destAddr"],
				});
			});
			return result;
		},

		async createNewAddress(this: Service, address: IAddress) {
			const entity = await this.broker.call<IAddress, any>("address.create", address);
			return entity;
		},
	},

	beforeEntityCreate(entity: IBooking) {
		if (entity.destAddr) {
			entity.destAddr = new MongoObjectId(entity.destAddr as string);
		}
		if (entity.pickupAddr) {
			entity.pickupAddr = new MongoObjectId(entity.pickupAddr as string);
		}

		entity.createdAt = new Date();
		entity.updatedAt = new Date();
		return entity;
	},

	beforeEntityUpdate(entity: IBooking) {
		entity.updatedAt = new Date();
		return entity;
	},
};

export default BookingService;
