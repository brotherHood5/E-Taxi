import type { Context, Service, ServiceSchema } from "moleculer";
// eslint-disable-next-line import/no-extraneous-dependencies
import { Queue } from "queue-typescript";
import type { IBooking } from "../../../entities";
import { BookingStatus } from "../../../entities";
import { AMQPMixin } from "../../../mixins";

// Danh sach nhan vien phan giai dia chi
// - Ranh - Dang khong lam gi
// - Ban - Dang lam viec

// Khi co cong viec moi
// - Neu co nhan vien ranh thi phan cong -> Ban
// - Neu khong co nhan vien ranh thi doi cho den khi co nhan vien ranh

// Khi nhan vien ban hoan thanh cong viec
// - Neu co cong viec trong hang doi thi phan cong -> Ban
// - Neu khong co cong viec trong hang doi thi chuyen sang ranh

const CoordSystemService: ServiceSchema = {
	name: "coordSystem",

	mixins: [AMQPMixin],

	settings: {
		rest: "/coord-system",
	},

	AMQPQueues: {
		"coordSystem.address_resolve": {
			async handler(this: Service, channel: any, msg: any): Promise<any> {
				const req = JSON.parse(msg.content.toString());
				const socketId = this.freeStaffQueue.shift();
				if (socketId) {
					this.addAMQPJob("monitorSystem.listen_event", {
						id: req._id,
						status: BookingStatus.COORDINATING,
						data: this.staffSocket[socketId],
					});
					await this.actions.sendBookingReqToStaff({ socketId, req });
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
				await ctx.call("socket.broadcast", {
					namespace: "/coord-system",
					event: "receive_booking",
					rooms: [ctx.params.socketId],
					args: [ctx.params.req],
				});
			},
		},

		resolvedAddress: {
			async handler(this: Service, ctx: Context<any, any>): Promise<void> {
				const { $socketId } = ctx.meta;
				const { req }: { req: IBooking } = ctx.params;
				if (req.status === BookingStatus.COORDINATING) {
					if (
						!req.pickupAddr.lat ||
						!req.pickupAddr.lon ||
						!req.destAddr.lat ||
						!req.destAddr.lon
					) {
						return Promise.reject(new Error("Invalid address, please check again"));
					}
				}

				// Free staff
				if (this.staffSocket[$socketId]) {
					this.freeStaffQueue.push($socketId);
				}

				this.addAMQPJob("bookingSystem.booking_process", req);
				return Promise.resolve();
			},
		},

		connect: {
			handler(this: Service, ctx: Context<any, any>): boolean {
				const { $socketId, user, $rooms } = ctx.meta;
				if (!this.staffSocket[$socketId]) {
					this.staffSocket[$socketId] = {
						fullName: user.fullName,
						id: user._id,
						$rooms,
						$socketId,
					};
					this.freeStaffQueue.push($socketId);
				}
				this.logger.info(this.staffSocket);
				return true;
			},
		},

		disconnect: {
			handler(this: Service, ctx: Context<any, any>): any {
				const socketId = ctx.params;

				// Remove socket from staffSocket
				if (this.staffSocket[socketId]) {
					delete this.staffSocket[socketId];
				}

				// Remove socket from freeStaffQueue
				const index = this.freeStaffQueue.indexOf(socketId);
				if (index !== -1) {
					this.freeStaffQueue.splice(index, 1);
				}

				return true;
			},
		},
	},

	methods: {},

	started() {
		this.logger.info("Coord System started!");
		this.staffSocket = {};
		this.freeStaffQueue = [];
	},

	async stopped() {
		await this.amqpDispose();
		this.staffSocket = {};
		this.freeStaffQueue = [];
	},
};

export default CoordSystemService;
