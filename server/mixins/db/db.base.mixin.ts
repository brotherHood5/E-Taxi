import DbService from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { DbServiceSchema, DbServiceThis } from "../../types/mixin/db";

export default abstract class DbBaseMixin {
	protected readonly cacheCleanEventName: string;

	protected readonly collection: string;

	constructor(collection: string) {
		this.collection = collection;
		this.cacheCleanEventName = `cache.clean.${this.collection}`;
	}

	getSchema(): DbServiceSchema {
		return this.create();
	}

	protected getBaseMixinSchema(): DbServiceSchema {
		return {
			mixins: [DbService],
			collection: this.collection,

			events: {
				/**
				 * Subscribe to the cache clean event. If it's triggered
				 * clean the cache entries for this service.
				 */
				async [this.cacheCleanEventName](this: DbServiceThis) {
					if (this.broker.cacher) {
						await this.broker.cacher.clean(`${this.fullName}.**`);
					}
				},
			},

			methods: {},

			async started() {
				// Check the count of items in the DB. If it's empty,
				// Call the `seedDB` method of the service.
				if (this.seedDB) {
					const count = await this.adapter.count();
					if (!count) {
						this.logger.info(
							`The collection for '${this.name}' is empty. Seeding the collection...`,
						);
						await this.seedDB();
						this.logger.info(
							"Seeding is done. Number of records:",
							await this.adapter.count(),
						);
					}
				}
			},
			/**
			 * Fired after database connection establishing.
			 */
			async afterConnected(this: DbServiceThis) {
				if ("collection" in this.adapter) {
					// Create indexes
					if (this.settings.indexes) {
						// Drop indexes
						this.logger.info(`Drop indexes of '${this.name}' collection...`);
						await (<MongoDbAdapter>this.adapter).collection
							.dropIndexes()
							.catch(() => {});

						await Promise.all(
							this.settings.indexes.map((index: any) => {
								const opt: { unique?: boolean } = {};
								if (index.unique) {
									opt.unique = Boolean(index.unique);
									delete index.unique;
								}

								return (<MongoDbAdapter>this.adapter).collection.createIndex(
									index,
									opt,
								);
							}),
						);
					}
				}
			},
		};
	}

	abstract create(): DbServiceSchema;
}
