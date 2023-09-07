import type { Service } from "moleculer";
import type { DbAdapter, DbServiceSettings, MoleculerDbMethods } from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { DriverEntity, IDriver } from "../../entities";
import type { AuthServiceSettings, DbServiceMethods } from "../mixin";
import type { GuardServiceSchema } from "./interfaces";

// Service
export interface DriversSettings extends DbServiceSettings, AuthServiceSettings {
	rest?: string;
	fields: (keyof Partial<IDriver>)[];
	indexes?: Record<string, number>[];
	populates?: any;
}

export interface DriversThis extends Service<DriversSettings>, MoleculerDbMethods {
	adapter: DbAdapter | MongoDbAdapter;
}

export type DriversServiceSchema = GuardServiceSchema<DriversSettings> & {
	methods: DbServiceMethods;
};

// Params
export type ActionCreateParams = Partial<IDriver>;
export type ActionUpdateParams = Partial<IDriver>;
