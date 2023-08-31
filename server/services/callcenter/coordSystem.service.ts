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
					req.status = BookingStatus.COORDINATING;
					await this.broker.call("bookingSystem.updateBookingStatus", {
						id: req._id,
						status: req.status,
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

				
				if (req.status === BookingStatus.COORDINATING) {
					if (
						!req.pickupAddr.lat ||
						!req.pickupAddr.lon ||
						!req.destAddr.lat ||
						!req.destAddr.lon
						) {
							return Promise.reject(new Error("Invalid address, please check again"));
						}
						// Cap nhat dia chi da phan giai vo db tuong duong cai dat xe do
						await this.broker.call("bookingSystem.updateBookingAddress", {
							id: req._id,
							pickupAddr: req.pickupAddr,
							destAddr: req.destAddr,
						});
				}
					
				this.addAMQPJob("booking.processing", req);
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
				this.logger.info(this.staffSocket);
				return true;
			},
		},

		disconnect: {
			handler(this: Service, ctx: Context<any, any>): any {
				const userId = ctx.params;
				this.logger.info("disconnect", userId);

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
				this.logger.info(this.staffSocket);
				return true;
			},
		},
	},

	methods: {},

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
