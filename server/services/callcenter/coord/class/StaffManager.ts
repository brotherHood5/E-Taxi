import { Queue } from "queue-typescript";
import QueueObservable from "../../../../core/class/ObservableQueue";

interface CoordStaffClient {
	id: string;
	res: any;
}

class StaffManager {
	private busyStaffs: Queue<CoordStaffClient>;

	private freeStaffs: Queue<CoordStaffClient>;

	constructor() {
		this.busyStaffs = new Queue<CoordStaffClient>();
		this.freeStaffs = new Queue<CoordStaffClient>();
	}

	addStaff(staff: CoordStaffClient): void {
		this.freeStaffs.enqueue(staff);
	}

	removeStaff(staff: CoordStaffClient): void {}
}

export default StaffManager;
