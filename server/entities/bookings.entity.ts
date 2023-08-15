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
	driver?: ObjectId;
	vehicleType: string;
	pickupAddr: IAddress;
	destAddr: IAddress;
	status: BookingStatus;
	count?: number;
	createdAt?: Date;
	updatedAt?: Date;
}
