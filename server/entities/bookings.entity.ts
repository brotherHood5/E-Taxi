/* eslint-disable @typescript-eslint/naming-convention */
import type { ObjectId, ObjectIdNull } from "../types/common";
import type { IAddress } from "./address.entity";

export enum BookingStatus {
	NEW = "NEW",
	COORDINATING = "COORDINATING",
	PROCESSING = "PROCESSING",
	ASSIGNED = "ASSIGNED",
	CANCELLED = "CANCELLED",
}

export interface IBooking {
	_id?: ObjectIdNull;
	phoneNumber: string;
	driverId?: ObjectIdNull;
	vehicleType: string;
	pickupAddr: IAddress | ObjectId;
	destAddr: IAddress | ObjectId;
	status: BookingStatus;
	createdAt?: Date;
	updatedAt?: Date;
}
