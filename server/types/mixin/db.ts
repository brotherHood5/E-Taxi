import type { Service, ServiceSchema } from "moleculer";

export type DbServiceMethods = {
	seedDB?(): Promise<void>;
};

export type DbServiceSchema = Partial<ServiceSchema> & {
	collection: string;
};

export type DbServiceThis = Service & DbServiceMethods;
