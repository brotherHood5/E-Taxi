import { UserRole } from "../types/common";
import type { ObjectIdNull } from "../types/common";

export interface IStaff {
	_id?: ObjectIdNull;
	username: string;
	passwordHash: string;
	fullName?: string;
	roles: UserRole[];
	createdAt?: Date;
	updatedAt?: Date;
}

export class StaffEntity implements IStaff {
	_id?: ObjectIdNull | undefined;

	username = "";

	passwordHash = "";

	fullName?: string | undefined = "";

	roles = [UserRole.STAFF];

	createdAt? = new Date();

	updatedAt? = new Date();
}
