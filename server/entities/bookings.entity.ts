import type { ObjectId, ObjectIdNull } from "../types/common";

export interface IBooking {
	_id?: ObjectIdNull;
	srcAddress: ObjectId;
	destAddress: ObjectId;
}
