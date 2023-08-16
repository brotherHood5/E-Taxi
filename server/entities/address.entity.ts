import type { ObjectIdNull } from "../types/common";

export interface IAddress {
	_id?: ObjectIdNull;
	homeNo: string;
	street: string;
	ward: string;
	district: string;
	city: string;
	lat?: number;
	lon?: number;
	createdAt?: Date;
	updatedAt?: Date;
}

export class AddressEntity implements IAddress {
	_id?: ObjectIdNull | undefined;

	homeNo = "";

	street = "";

	ward = "";

	district = "";

	city = "";

	lat = undefined;

	lon = undefined;

	createdAt = new Date();

	updatedAt = new Date();
}
