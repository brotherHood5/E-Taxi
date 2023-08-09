import type { Context, Service, ServiceSchema } from "moleculer";
// eslint-disable-next-line import/no-extraneous-dependencies
import { Queue } from "queue-typescript";
import { AMQPMixin } from "../../../mixins";
import JobObservableQueue from "./class/JobObservableQueue";
import NewJobObserver from "./class/NewJobObserver";

// class CoordStaffManager {
// 	private staffs: CoordStaffClient[];

// 	private availStaff: CoordStaffClient[];

// 	constructor() {
// 		this.staffs = [];
// 		this.availStaff = [];
// 	}

// 	addStaff(staff: any): void {
// 		this.staffs.push(staff);
// 	}

// 	getStaffs(): any[] {
// 		return this.staffs;
// 	}

// 	getAvailableStaff(): any {
// 		return this.availStaff.pop();
// 	}
// }

interface CoordStaffClient {
	id: string;
	res: any;
}

function writeSSEResponse(res: any, sseId: any, data: any) {
	try {
		res.write(`id: ${sseId}\n`);
		res.write(`data: ${data}\n\n`);
	} catch (error) {
		console.log(error);
	}
}

// Danh sach nhan vien phan giai dia chi
// - Ranh - Dang khong lam gi
// - Ban - Dang lam viec

// Khi co cong viec moi
// - Neu co nhan vien ranh thi phan cong -> Ban
// - Neu khong co nhan vien ranh thi doi cho den khi co nhan vien ranh

// Khi nhan vien ban hoan thanh cong viec
// - Neu co cong viec trong hang doi thi phan cong -> Ban
// - Neu khong co cong viec trong hang doi thi chuyen sang ranh

class CoordSystem {
	private pendingJobs: Queue<any>;

	private busyStaffs: Set<string> = new Set<string>();

	private freeStaffs: { [key: string]: any } = {};

	private runner?: NodeJS.Timer;

	constructor() {
		this.pendingJobs = new Queue<any>();
		// this.pendingJobs.attachObserver("enqueue", new NewJobObserver());
	}

	addStaff(staff: CoordStaffClient): void {
		console.log("Staff added: ", staff.id);
		this.freeStaffs[staff.id] = staff.res;
	}

	removeStaff(id: string): void {
		this.busyStaffs.delete(id);
		delete this.freeStaffs[id];
	}

	makeStaffBusy(id: string): void {
		if (this.busyStaffs.has(id)) {
			return;
		}
		this.busyStaffs.add(id);
	}

	makeStaffAvailable(id: string): void {
		if (!this.busyStaffs.has(id)) {
			return;
		}
		this.busyStaffs.delete(id);
	}

	addJob(job: any): void {
		this.pendingJobs.enqueue(job);
	}

	doJob(job: any): void {
		// try {
		// 	if (this.freeStaffs.length !== 0) {
		// 		console.log(
		// 			"Current",
		// 			this.staffs.toArray().map((s) => s.id),
		// 		);
		// 		const staff = this.staffs.dequeue();
		// 		this.busyStaffs.push(staff);
		// 		console.log("Staff: ", staff.id);
		// 		writeSSEResponse(staff.res, staff.id, job);
		// 		// this.pendingJobs.dequeue();
		// 		this.freeStaff(staff.id);
		// 		console.log(
		// 			"Current",
		// 			this.staffs.toArray().map((s) => s.id),
		// 		);
		// 	}
		// } catch (error) {
		// 	console.log(error);
		// }
	}

	run(): void {
		this.runner = setInterval(() => {
			if (this.pendingJobs.length === 0 || Object.keys(this.freeStaffs).length === 0) {
				return;
			}

			const job = this.pendingJobs.front;
			const staffId = Object.keys(this.freeStaffs)[0];
			const staffRes = this.freeStaffs[staffId];
			this.makeStaffBusy(staffId);
			writeSSEResponse(staffRes, staffId, job);
		}, 500);
	}

	stop(): void {
		clearInterval(this.runner);
	}
}

const CoordSystemService: ServiceSchema = {
	name: "coordSystem",

	mixins: [AMQPMixin],
	AMQPQueues: {
		"coord.system.receiveAddress": {
			handler(this: Service, channel: any, msg: any): void {
				const job = JSON.parse(msg.content.toString());
				this.$coordSystem.addJob(job);
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
		sse: {
			handler(this: Service, ctx: Context<any, any>): void {
				const res = ctx.params.$res;
				this.logger.info(ctx.meta.user);
				res.writeHead(200, {
					"Content-Type": "text/event-stream",
					"Cache-Control": "no-cache",
					Connection: "keep-alive",
				});
				// res.on("close", () => {
				// 	this.logger.info("Connection closed");
				// });

				// res.on("error", (err: any) => {
				// 	this.logger.error(err);
				// });
				const sseId = new Date().getTime().toString();
				writeSSEResponse(res, sseId, `Connected: ${sseId}`);
				this.$coordSystem.addStaff({ id: sseId, res });
				this.logger.info("Test");
			},
		},
	},

	methods: {},

	started() {
		this.logger.info("Coord System started!");
		this.$coordSystem = new CoordSystem();
		// for (let i = 0; i < 10; i += 1) {
		// 	this.$coordSystem.addJob({ id: i, data: `Hello ${i}` });
		// }

		this.$coordSystem.run();

		// for (let i = 10; i < 20; i += 1) {
		// 	this.$coordSystem.addJob({ id: i, data: `Hello ${i}` });
		// }
	},

	async stopped() {
		await this.AMQPdispose();
		this.logger.warn("Coord System stopped!");
		this.$coordSystem.stop();
	},
};

export default CoordSystemService;
