import type { ObjectId, ObjectIdNull } from "../types/common";

export interface IRefreshToken {
	_id?: ObjectIdNull;
	userId: ObjectId;
	token: string;
	expires: Date;
	createdAt?: Date;
	updatedAt?: Date;
}

export class RefreshToken implements IRefreshToken {
	_id?: ObjectIdNull = null;

	userId: ObjectId = "";

	token = "";

	expires: Date = new Date();

	createdAt?: Date = undefined;

	updatedAt?: Date = undefined;
}
