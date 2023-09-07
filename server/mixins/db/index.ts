import { Config } from "../../common";
import type { DbServiceSchema } from "../../types/mixin/db";
import type DbBaseMixin from "./db.base.mixin";
import DbMemoryMixin from "./db.memory.mixin";
import DbMongoMixin from "./db.mongo.mixin";

const TESTING = Config.NODE_ENV === "test";

// eslint-disable-next-line @typescript-eslint/naming-convention
export function DbMixin(collection: string): DbServiceSchema {
	let dbMixin: DbBaseMixin;

	if (TESTING) {
		dbMixin = new DbMemoryMixin(collection);
	} else if (Config.MONGO_URI) {
		dbMixin = new DbMongoMixin(collection);
	} else {
		throw new Error("Mongo URI not defined");
	}

	return dbMixin.getSchema();
}
