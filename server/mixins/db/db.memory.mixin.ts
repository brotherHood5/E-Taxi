import fs from "fs";
import DbService from "moleculer-db";
import type { DbServiceSchema } from "../../types/mixin/db";
import DbBaseMixin from "./db.base.mixin";

export default class DbMemoryMixin extends DbBaseMixin {
	create(): DbServiceSchema {
		const schema = super.getBaseMixinSchema();

		// Create data folder
		if (!fs.existsSync("./data")) {
			fs.mkdirSync("./data");
		}

		schema.adapter = new DbService.MemoryAdapter({
			filename: `./data/${this.collection}.db`,
		});

		return schema;
	}
}
