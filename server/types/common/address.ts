import type { Service } from "moleculer";
import type { DbAdapter, DbServiceSettings, MoleculerDbMethods } from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { AddressEntity, IAddress } from "../../entities";
import type { DbServiceMethods } from "../mixin";
import type { GuardServiceSchema } from "./interfaces";

// Service
export interface AddressSettings extends DbServiceSettings {
	rest?: string;
	fields: (keyof Partial<IAddress>)[];
	indexes?: Record<string, number>[];
	populates?: any;
}

export interface AddresssThis extends Service<AddressSettings>, MoleculerDbMethods {
	adapter: DbAdapter | MongoDbAdapter;
}

export type AddresssServiceSchema = GuardServiceSchema<AddressSettings> & {
	methods: DbServiceMethods;
};

// Params
export type ActionCreateParams = Partial<AddressEntity>;
export type ActionUpdateParams = Partial<AddressEntity>;
