import MongoDbAdapter from "moleculer-db-adapter-mongo";
import { Config } from "../../common";
import type { DbServiceSchema } from "../../types/mixin/db";
import DbBaseMixin from "./db.base.mixin";

export default class DbMongoMixin extends DbBaseMixin {
	create(): DbServiceSchema {
		const schema = super.getBaseMixinSchema();
		schema.adapter = new MongoDbAdapter(Config.MONGO_URI, {
			useNewUrlParser: true,
			useUnifiedTopology: true,
		});

		return schema;
	}
}
