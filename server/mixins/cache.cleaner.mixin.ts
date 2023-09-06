import type { ServiceSchema } from "moleculer";

// eslint-disable-next-line @typescript-eslint/naming-convention
export default function CacheCleanerMixin(serviceNames: string[]): Partial<ServiceSchema> {
	const events: { [key: string]: ServiceSchema } = {};

	serviceNames.forEach((name) => {
		events[`cache.clean.${name}`] = function clear() {
			if (this.broker.cacher) {
				this.logger.info(`Clear local '${this.name}' cache`);
				this.broker.cacher.clean(`${this.name}.**`);
			}
		};
	});

	return {
		events,
	};
}
