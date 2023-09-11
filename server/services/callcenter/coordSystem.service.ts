import type { Context, Service, ServiceSchema } from "moleculer";
import { BookingStatus } from "../../entities";
import type { IAddress, IBooking } from "../../entities";
import { AMQPMixin } from "../../mixins";

const CoordSystemService: ServiceSchema = {
	name: "coordSystem",

	mixins: [AMQPMixin],

	settings: {
		rest: "/coord-system",
	},

	AMQPQueues: {
		"booking.coordinating": {
			async handler(this: Service, channel: any, msg: any): Promise<any> {
				const req = JSON.parse(msg.content.toString());
				const userId = this.freeStaffQueue.shift();

				if (userId) {
					const staff = await this.broker.call("staffs.get", { id: userId });
					await this.broker.emit("booking.update", {
						...req,
						status: BookingStatus.COORDINATING,
						staff,
					});
					await this.actions.sendBookingReqToStaff({ userId, req });
					channel.ack(msg);
				} else {
					channel.nack(msg);
				}
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
		sendBookingReqToStaff: {
			async handler(this: Service, ctx: Context<any, any>): Promise<void> {
				this.staffsTask[ctx.params.userId] = { request: ctx.params.req };
				await ctx.call("socket.broadcast", {
					namespace: "/coord-system",
					event: "receive_booking",
					rooms: [ctx.params.userId],
					args: [ctx.params.req],
				});
			},
		},

		resolvedAddress: {
			async handler(this: Service, ctx: Context<any, any>): Promise<void> {
				const { user } = ctx.meta;
				const userId = user._id;

				const req = ctx.params as IBooking;
				req.pickupAddr = req.pickupAddr as IAddress;
				req.destAddr = req.destAddr as IAddress;

				if (
					!req.pickupAddr.lat ||
					!req.pickupAddr.lon ||
					!req.destAddr.lat ||
					!req.destAddr.lon
				) {
					return Promise.reject(new Error("Invalid address, please check again"));
				}

				// Cap nhat dia chi da phan giai vo db tuong duong cai dat xe do
				let value = await this.broker.call<IBooking, any>(
					"bookingSystem.updateBookingAddress",
					{
						id: req._id,
						pickupAddr: req.pickupAddr,
						destAddr: req.destAddr,
					},
				);

				const distance: number = this.distanceBetweenPoints(
					Number(req.pickupAddr.lat),
					Number(req.pickupAddr.lon),
					Number(req.destAddr.lat),
					Number(req.destAddr.lon),
				);
				const price: any = await ctx.call("price.calculatePrice", {
					vehicleType: req.vehicleType,
					distance,
				});

				value = await ctx.call("bookingSystem.update", {
					id: value._id,
					distance: (Math.round((distance + Number.EPSILON) * 1000) / 1000).toString(),
					price: price.toString(),
				});

				this.addAMQPJob("booking.processing", value);
				// Free staff
				if (userId && this.staffSocket[userId]) {
					delete this.staffsTask[userId];
					this.freeStaffQueue.push(userId);
				}

				return Promise.resolve();
			},
		},

		connect: {
			handler(this: Service, ctx: Context<any, any>): boolean {
				const { $socketId, user, $rooms } = ctx.meta;
				if (!this.staffSocket[user._id]) {
					this.staffSocket[user._id] = {
						fullName: user.fullName,
						id: user._id,
						$rooms,
						$socketId,
					};
					this.freeStaffQueue.push(user._id);
				}
				this.logger.debug("Connected:", this.staffSocket);
				return true;
			},
		},

		disconnect: {
			handler(this: Service, ctx: Context<any, any>): any {
				const userId = ctx.params;

				if (this.staffSocket[userId]) {
					// Remove socket from freeStaffQueue
					const index = this.freeStaffQueue.indexOf(userId);
					if (index !== -1) {
						// If no task, remove from freeStaffQueue
						this.freeStaffQueue.splice(index, 1);
					} else {
						// If has task
						// Requeue task
						const task = this.staffsTask[userId];
						delete this.staffsTask[userId];
						this.addAMQPJob("booking.coordinating", task.request);
					}

					// Remove socket from staffSocket
					delete this.staffSocket[userId];
				}
				this.logger.debug("Disconnect:", this.staffSocket);
				return true;
			},
		},
	},

	methods: {
		distanceBetweenPoints(
			this,
			lat1: number,
			lon1: number,
			lat2: number,
			lon2: number,
		): number {
			const R = 6371;
			const dLat = ((lat2 - lat1) * Math.PI) / 180;
			const dLon = ((lon2 - lon1) * Math.PI) / 180;
			lat1 = (lat1 * Math.PI) / 180;
			lat2 = (lat2 * Math.PI) / 180;
			const a =
				Math.sin(dLat / 2) ** 2 + Math.sin(dLon / 2) ** 2 * Math.cos(lat1) * Math.cos(lat2);
			const c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a));
			const d = R * c;
			return d;
		},
	},

	started() {
		this.staffSocket = {};
		this.staffsTask = {};
		this.freeStaffQueue = [];
	},

	async stopped() {
		await this.amqpDispose();
		this.staffSocket = {};
		this.freeStaffQueue = [];
	},
};

export default CoordSystemService;
