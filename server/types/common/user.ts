/* eslint-disable @typescript-eslint/naming-convention */
import type { ApiGatewayMeta, ObjectIdNull } from "./interfaces";

// User definition
export enum UserRole {
	ADMIN = "ADMIN",
	STAFF = "STAFF",
	CUSTOMER = "CUSTOMER",
	DRIVER = "DRIVER",
	VIP_CUSTOMER = "VIP_CUSTOMER",
}

export interface IUserBase {
	_id?: ObjectIdNull;
	phoneNumber: string;
	passwordHash: string;
	phoneNumberVerified: boolean;
	enable: boolean;
	active: boolean;
	roles: UserRole[];
	createdAt?: Date;
	updatedAt?: Date;
	fullName?: string;
}

export interface UserAuthMeta extends ApiGatewayMeta {
	user: IUserBase;
}
