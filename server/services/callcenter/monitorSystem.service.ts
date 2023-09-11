import type { Channel } from "amqplib";
import type { Context, Service, ServiceSchema } from "moleculer";
import type { IBooking } from "../../entities";
import { BookingStatus } from "../../entities";
import { AMQPMixin, DbMixin } from "../../mixins";
import { MongoObjectId } from "../../types/common";

const MonitorSystemService: ServiceSchema = {
	name: "monitorSystem",
	mixins: [AMQPMixin, DbMixin("booking_logs")],
	dependencies: ["bookingSystem", "socket"],
	settings: {
		fields: ["_id", "bookingId", "logs", "detail", "createdAt", "updatedAt"],
		entityValidator: {
			bookingId: ["string", { type: "objectID", ObjectID: MongoObjectId }],
			logs: {
				type: "array",
				items: "string",
			},
			createdAt: "date",
			updatedAt: "date",
		},
		populates: {
			detail: {
				field: "bookingId",
				action: "bookingSystem.get",
			},
		},
		indexes: [{ bookingId: 1, unique: true }],
	},

	AMQPQueues: {
		"monitor.create": {
			async handler(this: Service, channel: Channel, msg: any): Promise<void> {
				try {
					const request = JSON.parse(msg.content.toString()) as IBooking;
					await this.actions.create({
						bookingId: request._id?.toString(),
						logs: [this.getMsg(request)],
					});
					channel.ack(msg);
				} catch (err) {
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

		"monitor.update": {
			async handler(this: Service, channel: any, msg: any): Promise<void> {
				try {
					const params: any = JSON.parse(msg.content.toString());
					const log = this.getMsg(params.request, params.data);
					await this.actions.addLog({ _id: params.request._id, log });
					channel.ack(msg);
				} catch (error) {
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
		addLog: {
			async handler(this: Service, ctx: Context<any, any>): Promise<void> {
				const { _id, log } = ctx.params;
				const doc: any = await this.adapter.findOne({
					bookingId: new MongoObjectId(_id?.toString()),
				});
				doc.logs.push(log);
				let result = await this.adapter.updateById(doc._id, {
					$set: { logs: doc.logs },
				});
				result = await this.transformDocuments(
					ctx,
					{
						populate: ["detail"],
					},
					doc,
				);

				await this.broker.call("socket.broadcast", {
					namespace: "/monitor",
					event: "log",
					args: [result],
				});
			},
		},

		find: {
			cache: false,
		},
	},

	methods: {
		getMsg(this: Service, request: IBooking, data: any): string {
			let msg = "";
			switch (request.status) {
				case BookingStatus.NEW: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: New booking request`;
					break;
				}
				case BookingStatus.COORDINATING: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Coordinating address by [${data.staff._id} - ${data.staff.fullName}]}`;
					break;
				}
				case BookingStatus.PROCESSING: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Processing the request. Finding driver...`;
					break;
				}
				case BookingStatus.ASSIGNED: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Assigned to driver [${request.driverId} - ${request.driver?.fullName}]`;
					break;
				}
				case BookingStatus.DRIVER_CANCELLED: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Driver Cancelled`;
					break;
				}
				case BookingStatus.CUSTOMER_CANCELLED: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Customer Cancelled`;
					break;
				}
				case BookingStatus.ON_GOING: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: On going`;
					break;
				}
				case BookingStatus.DONE: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Done`;
					break;
				}
				case BookingStatus.FAILED: {
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Failed`;
					break;
				}
				default:
					msg = `[${new Date().toUTCString()} - ${request._id} - ${
						request.phoneNumber
					}]: Unknown status`;
					break;
			}

			return msg;
		},
	},

	beforeEntityCreate(entity: any) {
		if (entity.bookingId) {
			entity.bookingId = new MongoObjectId(entity.bookingId as string);
		}
		entity.createdAt = new Date();
		entity.updatedAt = new Date();
		return entity;
	},

	beforeEntityUpdate(entity: any) {
		entity.updatedAt = new Date();
		return entity;
	},

	started() {},

	stopped() {},
};

export default MonitorSystemService;
