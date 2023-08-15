import { UserRole } from "../types/common";
import type { IUserBase, ObjectIdNull } from "../types/common";

export type ICustomer = IUserBase;

export class CustomerEntity implements ICustomer {
	_id?: ObjectIdNull;

	phoneNumber = "";

	passwordHash = "";

	fullName?: string | undefined = "";

	phoneNumberVerified = false;

	enable = true;

	active = true;

	roles = [UserRole.CUSTOMER];

	createdAt? = new Date();

	updatedAt? = new Date();
}
