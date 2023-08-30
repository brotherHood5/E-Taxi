import type { Cachers, Service, ServiceSchema } from "moleculer";
import { Config } from "../../common";
import type { AddressEntity, IAddress, IBooking, IDriver } from "../../entities";
import { BookingStatus, VehicleType } from "../../entities";
import { AMQPMixin, DbMixin } from "../../mixins";
import type { ObjectId } from "../../types";
import { MongoObjectId } from "../../types";
import { DriverFinder } from "./core";

const BookingService: ServiceSchema = {
	name: "bookingSystem",
	authToken: Config.BOOKING_AUTH_TOKEN,
	mixins: [DbMixin("bookings"), AMQPMixin],

	events: {
		"drivers.logged": {
			handler(this: Service, ctx: any) {
				this.logger.warn("Driver logged: ", this.loggedDriver);
				this.loggedDriver.add(ctx.params);
			},
		},
		"drivers.updateLocation": {
			handler(this: Service, ctx: any) {
				this.logger.warn("Driver update location: ", ctx.params);
			},
		},
		"drivers.updateStatus": {
			handler(this: Service, ctx: any) {
				this.logger.warn("Driver update status: ", ctx.params);
			},
		},
	},

	settings: {
		rest: "/booking-system",
		fields: [
			"_id",
			"phoneNumber",
			"customerId",
			"driverId",
			"driver",
			"vehicleType",
			"pickupAddr",
			"destAddr",
			"status",
			"price",
			"distance",
			"inApp",
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
		"booking.processing": {
			async handler(this: Service, channel: any, msg: any): Promise<void> {
				const req = JSON.parse(msg.content.toString());
				req.status = BookingStatus.PROCESSING;
				try {
					await this.actions.updateBookingStatus({
						id: req._id,
						status: req.status,
					});

					// TODO: Find Driver
					channel.ack(msg);
				} catch (error) {
					channel.nack(msg);
				}
			},
		},

		"booking.new": {
			handler(this: Service, channel: any, msg: any): void {
				const req = JSON.parse(msg.content.toString()) as IBooking;
				req.status = BookingStatus.NEW;

				req.destAddr = req.destAddr as AddressEntity;
				req.pickupAddr = req.pickupAddr as AddressEntity;

				if (
					!req.pickupAddr.lat ||
					!req.pickupAddr.lon ||
					!req.destAddr.lat ||
					!req.destAddr.lon
				) {
					// Chuyen qua phan giai dia chi
					this.addAMQPJob("booking.coordinating", req);
				} else {
					// Xu li dat xe
					this.addAMQPJob("booking.processing", req);
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
					vehicleType: VehicleType.FOUR_SEATS,
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
				this.addAMQPJob("booking.new", result);
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
			async handler(this: Service, ctx: any) {
				const result = await this.createNew({ ...ctx.params, inApp: true });
				this.addAMQPJob("booking.new", result);
				return result;
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
				const result = await this.createNew(ctx.params);
				this.addAMQPJob("booking.new", result);
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

		updateDriverLocation: {
			params: {
				lon: "number",
				lat: "number",
				customerId: "string|optional",
			},
			handler(this: Service, ctx: any) {
				const { lon, lat, customerId } = ctx.params;
				const { user } = ctx.meta;
				const driverId = user._id;

				// Gui thong tin vi tri cua driver toi customer
				if (customerId) {
					ctx.call("socket.broadcast", {
						namespace: "/customers",
						room: [customerId],
						event: "driver_update_location",
						args: [
							{
								driverId: user._id,
								lon,
								lat,
							},
						],
					});
				}

				// Cap nhat vi tri cua driver vao redis
				this.geoadd(lon, lat, driverId);
			},
		},

		updateDriverStatus: {
			params: {
				status: "string",
			},
			handler(this: Service, ctx: any) {},
		},

		getBookingHistory: {
			rest: "GET /history",
			params: {
				phoneNumber: "string",
			},
			async handler(this: Service, ctx: any): Promise<any> {
				const { phoneNumber } = ctx.params;
				const data = await this.actions.find({
					query: { phoneNumber, inApp: undefined },
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
				status: BookingStatus.NEW,
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
			if (!data.inApp) {
				await this.broker.call("address_customer.increaseCount", {
					phoneNumber: entity.phoneNumber,
					addressId: entity.destAddr,
					value: 1,
				});
			}

			const result = await this.actions.create(entity).then((res) =>
				this.actions.get({
					id: res._id?.toString(),
					populate: ["pickupAddr", "destAddr"],
				}),
			);
			return result;
		},

		async createNewAddress(this: Service, address: IAddress) {
			const entity = await this.broker.call<IAddress, any>("address.create", address);
			return entity;
		},

		async geoadd(this: Service, lon, lat, driverId) {
			await this.redisClient.geoadd(`${this.prefix}.drivers_location`, lon, lat, driverId);
		},

		async remove(this: Service, dirverId) {
			await this.redisClient.zrem(`${this.prefix}.drivers_location`, dirverId);
		},

		async findNearby(this: Service, lat: number, lon: number, maxRadius = 5, isAsc = true) {
			const result = await this.redisClient.geosearch(
				`${this.prefix}.drivers_location`,
				"FROMLONLAT",
				lon,
				lat,
				"BYRADIUS",
				maxRadius,
				"km",
				isAsc ? "ASC" : "DESC",
				"WITHDIST",
				"WITHCOORD",
			);
			return result;
		},
	},

	created() {},

	started() {
		this.loggedDriver = new Set<IDriver>();
		this.activeDriver = [];
		this.driverFinder = new DriverFinder();

		this.redisClient = (this.broker.cacher as Cachers.Redis).client;
		this.prefix = `${(this.broker.cacher as Cachers.Redis).prefix}${this.name}`;
	},

	async stopped() {
		if (this.redisClient) {
			await this.redisClient.del(`${this.prefix}.drivers_location`);
		}
	},

	beforeEntityCreate(entity: IBooking) {
		if (entity.customerId) {
			entity.customerId = new MongoObjectId(entity.customerId as string);
		}

		if (entity.driverId) {
			entity.driverId = new MongoObjectId(entity.driverId as string);
		}

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
