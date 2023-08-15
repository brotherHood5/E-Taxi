import type { ServiceSchema } from "moleculer";

export default (serviceNames: string[]): Partial<ServiceSchema> => {
	const events: { [key: string]: ServiceSchema } = {};

	serviceNames.forEach((name) => {
		events[`cache.clean.${name}`] = function clear() {
			if (this.broker.cacher) {
				this.logger.debug(`Clear local '${this.name}' cache`);
				this.broker.cacher.clean(`${this.name}.**`);
			}
		};
	});

	return {
		events,
	};
};
