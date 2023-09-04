/* eslint-disable @typescript-eslint/naming-convention */
import type { ObjectId, ObjectIdNull } from "../types/common";
import type { IAddress } from "./address.entity";
import type { VehicleType } from "./driver.entity";

export enum BookingStatus {
	NEW = "NEW",
	COORDINATING = "COORDINATING",
	PROCESSING = "PROCESSING",
	ASSIGNED = "ASSIGNED",
	ON_GOING = "ON_GOING",

	DRIVER_CANCELLED = "DRIVER_CANCELLED",
	CUSTOMER_CANCELLED = "CUSTOMER_CANCELLED",

	FAILED = "FAILED",
	DONE = "DONE",
}

export interface IBooking {
	_id?: ObjectIdNull;
	phoneNumber: string;
	customerId?: ObjectIdNull;
	driverId?: ObjectIdNull;
	vehicleType: VehicleType;
	pickupAddr: IAddress | ObjectId;
	destAddr: IAddress | ObjectId;
	status: BookingStatus;
	createdAt?: Date;
	updatedAt?: Date;
	price?: string;
	distance?: number;
	inApp?: boolean;
}
