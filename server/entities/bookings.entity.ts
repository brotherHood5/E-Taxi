/* eslint-disable @typescript-eslint/naming-convention */
import type { ObjectId, ObjectIdNull } from "../types/common";
import type { IAddress } from "./address.entity";
import type { VehicleType } from "./driver.entity";

export enum BookingStatus {
	NEW = "NEW", // Moi tao
	COORDINATING = "COORDINATING", // Dang dinh vi
	PROCESSING = "PROCESSING", // Dang xu ly tim tai xe
	ASSIGNED = "ASSIGNED", // Tai xe xac nhan
	ON_GOING = "ON_GOING", // Tai xe dang di

	DRIVER_CANCELLED = "DRIVER_CANCELLED", // Tai xe huy
	CUSTOMER_CANCELLED = "CUSTOMER_CANCELLED", // Khach hang huy

	FAILED = "FAILED", // That bai
	DONE = "DONE", // Hoan thanh
}

export interface IBooking {
	_id?: ObjectIdNull;
	phoneNumber: string;
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
