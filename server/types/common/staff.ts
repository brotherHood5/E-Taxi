import type { Service } from "moleculer";
import type { DbAdapter, DbServiceSettings, MoleculerDbMethods } from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { StaffEntity } from "../../entities";
import type { AuthServiceSettings, DbServiceMethods } from "../mixin";
import type { GuardServiceSchema } from "./interfaces";

// Service
export interface StaffsSettings extends DbServiceSettings, Partial<AuthServiceSettings> {
	rest?: string;
	fields: (keyof Partial<StaffEntity>)[];
	indexes?: Record<string, number>[];
	populates?: any;
}

export interface StaffsThis extends Service<StaffsSettings>, MoleculerDbMethods {
	adapter: DbAdapter | MongoDbAdapter;
}

export type StaffsServiceSchema = GuardServiceSchema<StaffsSettings> & {
	methods: DbServiceMethods;
};

// Params
export type ActionCreateParams = Partial<StaffEntity>;
export type ActionUpdateParams = Partial<StaffEntity>;
