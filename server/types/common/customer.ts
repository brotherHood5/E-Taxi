import type { Service } from "moleculer";
import type { DbAdapter, DbServiceSettings, MoleculerDbMethods } from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { CustomerEntity } from "../../entities";
import type { AuthServiceSettings, DbServiceMethods } from "../mixin";
import type { GuardServiceSchema } from "./interfaces";

// Service
export interface CustomersSettings extends DbServiceSettings, AuthServiceSettings {
	rest?: string;
	fields: (keyof Partial<CustomerEntity>)[];
	indexes?: Record<string, number>[];
	populates?: any;
}

export interface CustomersThis extends Service<CustomersSettings>, MoleculerDbMethods {
	adapter: DbAdapter | MongoDbAdapter;
}

export type CustomersServiceSchema = GuardServiceSchema<CustomersSettings> & {
	methods: DbServiceMethods;
};

// Params
export type ActionCreateParams = Partial<CustomerEntity>;
export type ActionUpdateParams = Partial<CustomerEntity>;
