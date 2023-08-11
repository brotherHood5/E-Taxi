import type { Service, ServiceSchema } from "moleculer";
import type { DriverEntity, IBooking, StaffEntity } from "../../../entities";
import { BookingStatus } from "../../../entities";
import { AMQPMixin } from "../../../mixins";

const MonitorSystemService: ServiceSchema = {
	name: "monitorSystem",
	mixins: [AMQPMixin],
	AMQPQueues: {
		"monitorSystem.booking_monitor": {
			handler(this: Service, channel: any, msg: any): void {
				const request = JSON.parse(msg.content.toString()) as IBooking;
				this.add(request);
				channel.ack(msg);
			},
		},

		"monitorSystem.listen_event": {
			handler(this: Service, channel: any, msg: any): void {
				const { id, status, data } = JSON.parse(msg.content.toString());
				this.logs(id, status, data);
				channel.ack(msg);
			},
		},
	},

	methods: {
		add(this: Service, request: IBooking) {
			this.bookings_requests.push(request);
			this.addAMQPJob("monitorSystem.listen_event", {
				id: request._id,
				status: request.status,
			});
		},

		remove(this: Service, id: string) {
			const index = this.bookings_requests.findIndex((req: IBooking) => req._id === id);
			if (index !== -1) {
				this.bookings_requests.splice(index, 1);
			}
		},

		async logs(this: Service, id: string, status?: any, data?: any): Promise<boolean> {
			const request = this.bookings_requests.find((req: IBooking) => req._id === id);
			if (!request) {
				return false;
			}

			this.logger.info(request);
			request.status = status;

			let msg = "";
			switch (status) {
				case BookingStatus.NEW: {
					msg = `[${request.phoneNumber}] - New booking request`;
					break;
				}
				case BookingStatus.COORDINATING: {
					msg = `[${request.phoneNumber}] - Coordinating address by [${data.id}] - ${data.fullName}}`;
					break;
				}
				case BookingStatus.PROCESSING: {
					msg = `[${request.phoneNumber}] - Processing the request. Finding driver...`;
					break;
				}
				case BookingStatus.ASSIGNED: {
					msg = `[${request.phoneNumber}] - Assigned to driver [${data.id}] - ${data.fullName}`;
					break;
				}
				case BookingStatus.CANCELLED: {
					msg = `[${request.phoneNumber}] - Cancelled`;
					break;
				}
				default:
					msg = `[${request.phoneNumber}] - Unknown status`;
					break;
			}
			await this.broker.call("socket.broadcast", {
				namespace: "/monitor",
				event: "log",
				args: [msg],
			});

			return true;
		},
	},

	started() {
		this.bookings_requests = [];
	},

	stopped() {
		this.bookings_requests.length = 0;
	},
};

export default MonitorSystemService;
