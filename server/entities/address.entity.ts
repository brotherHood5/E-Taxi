import type { ObjectIdNull } from "../types/common";

export interface IAddress {
	_id?: ObjectIdNull;
	formattedAddress: string;
	lat: number | undefined;
	lon: number | undefined;
	createdAt?: Date;
	updatedAt?: Date;
}

export class Address implements IAddress {
	formattedAddress = "";

	lat = undefined;

	lon = undefined;

	createdAt = new Date();

	updatedAt = new Date();
}
