import type { Channel } from "amqplib";
import type { Cachers, Context, Service, ServiceSchema } from "moleculer";
import { Config } from "../../common";
import type { AddressEntity, IAddress, IBooking, IDriver } from "../../entities";
import { BookingStatus, DriverStatus } from "../../entities";
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
			"customerId",
			"customer",
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
				action: "drivers.get",
				params: {
					fields: "_id fullName phoneNumber vehicleType",
				},
			},
			customer: {
				field: "customerId",
				action: "customers.get",
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

		driverAcceptTimeout: JSON.parse(process.env.DRIVER_ACCEPT_TIMEOUT ?? "10"),
	},

	events: {
		"booking.update": {
			params: {
				_id: "string",
			},
			async handler(this: Service, ctx: Context<any, any>) {
				const { _id, status, driverId, staff } = ctx.params;
				const result: IBooking = await ctx.call("bookingSystem.updateAndGet", {
					id: _id,
					status,
					driverId,
				});

				this.logger.info("Booking updated status: ", result);
				this.addAMQPJob("monitor.update", {
					request: result,
					data: {
						staff,
					},
				});

				// Send notification
				switch (result.status) {
					case BookingStatus.ASSIGNED: {
						// Lay thong tin vi tri cua driver
						const driverGeo = await this.geopos(result.driverId);
						if (driverGeo) {
							if (result.customerId && result.inApp) {
								await ctx.emit("socket.appNotify", {
									namespace: "/customers",
									event: "driver_accepted",
									args: [
										{
											booking: result, // Thong tin booking
											driver: {
												// Thong tin driver
												driverId: result.driverId,
												lat: driverGeo[0][1],
												lon: driverGeo[0][0],
											},
										},
									],
									rooms: [result.customerId.toString()],
								});
							} else {
								const { driver } = result as any;
								await ctx.emit("socket.smsNotify", {
									to: result.phoneNumber,
									message: `Tai xe da nhan. Tai xe: ${driver.fullName} - SDT:${driver.phoneNumber}`,
								});
							}
							await this.geoRemove(result.driverId);
						}
						break;
					}
					case BookingStatus.FAILED: {
						if (result.customerId && result.inApp) {
							await ctx.emit("socket.appNotify", {
								namespace: "/customers",
								event: "booking_updated",
								args: [result],
								room: [result.customerId.toString()],
							});
						} else {
							await ctx.emit("socket.smsNotify", {
								to: result.phoneNumber,
								message: `Xin loi, hien tai chung toi khong co tai xe phu hop voi yeu cau cua ban. Xin vui long thu lai sau.`,
							});
						}
						break;
					}
					case BookingStatus.DONE: {
						if (result.customerId && result.inApp) {
							await ctx.emit("socket.appNotify", {
								namespace: "/customers",
								event: "booking_updated",
								args: [result],
								room: [result.customerId.toString()],
							});
						} else {
							await ctx.emit("socket.smsNotify", {
								to: result.phoneNumber,
								message: `Chuyen di da hoan thanh`,
							});
						}break;
					}				
					default:
						break;
				}

				return result as any;
			},
		},

		"booking.driversFound": {
			handler(this: Service, ctx: any) {
				const { req, drivers } = ctx.params;

				// Gui thong bao den tai xe
				ctx.call("socket.notify", {
					provider: "app",
					data: {
						namespace: "/drivers",
						rooms: drivers.map((item: IDriver) => item._id),
						event: "booking_found",
						args: [req],
					},
				});

				setTimeout(() => {
					ctx.emit("booking.noDriversFound", req);
				}, (this.settings.driverAcceptTimeout as number) * 1000);

				return drivers;
			},
		},

		"booking.noDriversFound": {
			async handler(this: Service, ctx: any) {
				const booking = await ctx.call("bookingSystem.get", { id: ctx.params._id });
				if (booking.status === BookingStatus.PROCESSING) {
					await ctx.emit("booking.update", {
						_id: ctx.params._id,
						status: BookingStatus.FAILED,
					});
				}
			},
		},
	},

	AMQPQueues: {
		"booking.findDrivers": {
			async handler(this: Service, channel: Channel, msg: any): Promise<void> {
				try {
					const req = JSON.parse(msg.content.toString());

					// Tim tai xe gan nhat
					await this.broker
						.call("bookingSystem.findDrivers", {
							lat: (req.pickupAddr as IAddress).lat,
							lon: (req.pickupAddr as IAddress).lon,
							vehicleType: req.vehicleType,
						})
						.then((drivers: any) => {
							this.logger.info("Find drivers: ", drivers);
							if (drivers.length !== 0) {
								// Tim thay tai xe
								this.broker
									.emit("booking.driversFound", {
										req,
										drivers,
									})
									.then(() => {})
									.catch(() => {});
							} else {
								// Khong tim thay tai xe
								this.broker
									.emit("booking.noDriversFound", req)
									.then(() => {})
									.catch(() => {});
							}
						})
						.catch((err) => {
							this.broker
								.emit("booking.noDriversFound", req)
								.then(() => {})
								.catch(() => {});
						});
					channel.ack(msg);
				} catch (error) {
					channel.ack(msg);
				}
			},
			channel: {
				assert: {
					durable: true,
				},
				prefetch: 5,
			},
			consume: {
				noAck: false,
			},
		},

		"booking.new": {
			handler(this: Service, channel: any, msg: any): void {
				const req = JSON.parse(msg.content.toString()) as IBooking;
				req.destAddr = req.destAddr as AddressEntity;
				req.pickupAddr = req.pickupAddr as AddressEntity;

				if (
					req.pickupAddr.lat === null ||
					req.pickupAddr.lon === null ||
					req.destAddr.lat === null ||
					req.destAddr.lon === null
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
				prefetch: 5,
			},
			consume: {
				noAck: false,
			},
		},

		"booking.processing": {
			async handler(this: Service, channel: Channel, msg: any): Promise<void> {
				const req = JSON.parse(msg.content.toString());
				req.status = BookingStatus.PROCESSING;
				try {
					const result = (await this.broker.emit(
						"booking.update",
						req,
					)) as unknown as IBooking[];
					this.addAMQPJob("booking.findDrivers", result[0]);
					channel.ack(msg);
				} catch (error) {
					channel.nack(msg);
				}
			},
			channel: {
				assert: {
					durable: true,
				},
				prefetch: 5,
			},
			consume: {
				noAck: false,
			},
		},
	},

	actions: {
		// Driver
		driverConnected: {
			params: {
				lat: ["number", "string"],
				lon: ["number", "string"],
			},
			async handler(this: Service, ctx: any) {
				let { lat, lon } = ctx.params;

				try {
					lat = Number(lat);
					lon = Number(lon);
					await ctx.call("bookingSystem.updateDriverLocation", {
						lat,
						lon,
					});
					await ctx.emit("drivers.connected");
				} catch (error) {
					return false;
				}
				return true;
			},
		},

		driverDisconnected: {
			async handler(this: Service, ctx: Context<any, any>) {
				const id = ctx.params;
				this.geoRemove(id);
				await ctx.emit("drivers.disconnected", id);
			},
		},

		findDrivers: {
			async handler(this: Service, ctx: any) {
				const { lat, lon, vehicleType, maxRadius } = ctx.params;
				const result = await this.findNearby(lat, lon, maxRadius);
				const drivers = await ctx.call("drivers.find", {
					query: {
						_id: {
							$in: result.map((item: any) => new MongoObjectId(item[0])),
						},
						vehicleType,
						driverStatus: DriverStatus.ACTIVE,
					},
				});

				return drivers;
			},
		},

		driverAccept: {
			rest: "POST /driver-accept",
			async handler(this: Service, ctx: any): Promise<any> {
				const { user } = ctx.meta;
				const driverId = user._id;
				const data = ctx.params as IBooking;

				try {
					const fetchedBooking: IBooking = await this.actions.get({
						id: data._id,
						populate: ["pickupAddr", "destAddr", "driver", "customer"],
					});
					// Kiem tra xem booking co ton tai khong
					if (!fetchedBooking) {
						throw new Error("Booking not found");
					} else if (fetchedBooking.status !== BookingStatus.PROCESSING) {
						throw new Error("Booking time out");
					} else if (fetchedBooking.driverId) {
						// Kiem tra xem booking da duoc accept boi driver khac chua
						throw new Error("Booking has been accepted by another driver");
					} else {
						// Kiem tra xem booking co bi lock boi driver khac khong
						const result = await this.redisClient.set(
							`${this.prefix}.driver_accept:${data._id}`,
							driverId,
							"NX",
							"EX",
							10,
						);
						if (!result) {
							throw new Error("Booking has been accepting by another driver");
						}
					}

					await this.broker.emit("drivers.updateStatus", {
						id: driverId,
						driverStatus: DriverStatus.ON_GOING,
					});
					const result: any = await this.broker.emit("booking.update", {
						_id: data._id,
						driverId,
						status: BookingStatus.ASSIGNED,
					});
					return result[0];
				} catch (error) {
					throw new Error(error);
				}
			},
		},

		driverFinish: {
			async handler(this: Service, ctx: any) {
				const { user } = ctx.meta;
				const driverId = user._id;
				const data = ctx.params as IBooking;

				const result = await Promise.allSettled([
					this.broker.emit("drivers.updateStatus", {
						id: driverId,
						driverStatus: DriverStatus.ACTIVE,
					}),
					this.broker.emit("booking.update", {
						_id: data._id,
						status: BookingStatus.DONE,
					}),
				]);
				
				return result;
			},
		},

		updateDriverLocation: {
			params: {
				lon: "number",
				lat: "number",
				customerId: "string|optional",
				inApp: "boolean|optional",
				phoneNumber: "string|optional",
			},
			handler(this: Service, ctx: any) {
				const { lon, lat, customerId, inApp, phoneNumber } = ctx.params;
				const { user } = ctx.meta;
				const driverId = user._id;

				// Gui thong tin vi tri cua driver toi customer
				if (customerId || phoneNumber) {
					ctx.call("socket.notify", {
						provider: inApp ? "app" : "sms",
						data: inApp
							? {
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
							  }
							: {
									to: phoneNumber,
									message: `Tai xe dang o vi tri: ${lat}, ${lon}`,
							  },
					});
				} else {
					// Cap nhat vi tri cua driver vao redis
					this.geoadd(lon, lat, driverId);
				}
			},
		},
		// -----------------------------

		// Done
		// -----------------------------
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
				pickupAddr: "object|optional",
				destAddr: "object|optional",
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

				return this.transformDocuments(
					ctx,
					{
						populate: ["pickupAddr", "destAddr"],
					},
					result[0],
				);
			},
		},

		updateAndGet: {
			params: {
				id: "string",
			},
			async handler(this: Service, ctx: Context<any, any>): Promise<IBooking> {
				const { id, status, driverId } = ctx.params;
				return new this.Promise((resolve, reject) => {
					ctx.call<IBooking, any>(
						"bookingSystem.update",
						driverId
							? {
									id,
									status,
									driverId,
							  }
							: { id, status },
					)
						.then((res) =>
							this.transformDocuments(
								ctx,
								{
									populate: ["pickupAddr", "destAddr", "driver", "customer"],
								},
								res,
							)
								.then(resolve)
								.catch(reject),
						)
						.catch(reject);
				});
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
							if (!data.inApp) {
								this.broker
									.call("address_customer.create", {
										phoneNumber: entity.phoneNumber,
										addressId: destAddr._id,
										count: -1,
									})
									.then(resolve)
									.catch(reject);
							} else {
								resolve(true);
							}
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
			this.addAMQPJob("monitor.create", result);
			return result;
		},

		async createNewAddress(this: Service, address: IAddress) {
			const entity = await this.broker.call<IAddress, any>("address.create", address);
			return entity;
		},

		async geoadd(this: Service, lon: number, lat: number, driverId: string) {
			await this.redisClient.geoadd(this.driversLocationKey, lon, lat, driverId);
		},

		geopos(this: Service, driverId: string) {
			return this.redisClient.geopos(this.driversLocationKey, driverId);
		},

		async geoRemove(this: Service, driverId: string) {
			await this.redisClient.zrem(this.driversLocationKey, driverId);
		},

		async findNearby(this: Service, lat: number, lon: number, maxRadius = 5, isAsc = true) {
			const result = await this.redisClient.geosearch(
				this.driversLocationKey,
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

	started() {
		this.redisClient = (this.broker.cacher as Cachers.Redis).client;
		this.prefix = `${(this.broker.cacher as Cachers.Redis).prefix}${this.name}`;
		this.driversLocationKey = `${this.prefix}:drivers_location`;
	},

	async stopped() {
		// Xoa tat ca driver dang online
		if (this.redisClient) {
			await this.redisClient.del(this.driversLocationKey);
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
		if (entity.customerId) {
			entity.customerId = new MongoObjectId(entity.customerId as string);
		}
		if (entity.driverId) {
			entity.driverId = new MongoObjectId(entity.driverId as string);
		}
		entity.updatedAt = new Date();
		return entity;
	},
};

export default BookingService;
