import type { IncomingHttpHeaders } from "http";
import type {
	ActionHandler,
	ActionSchema,
	ServiceActionsSchema,
	ServiceSchema,
	ServiceSettingSchema,
} from "moleculer";
import { ObjectId as MongoObjectId } from "mongodb";
import type { UserRole } from "./user";

export { MongoObjectId };
export type ObjectId = MongoObjectId | string;
export type ObjectIdNull = ObjectId | null;

export interface ApiGatewayMeta {
	$statusCode?: number;
	$statusMessage?: string;
	$responseType?: string;
	$responseHeaders?: any;
	$location?: string;
	$requestHeaders?: IncomingHttpHeaders | object;
	userAgent?: string | null | undefined;
	user?: object | null | undefined;
}

interface GuardActionSchema extends ActionSchema {
	restricted?: string[];
	auth?: boolean;
	roles?: UserRole | UserRole[];
}

export interface GuardServiceActionsSchema extends ServiceActionsSchema {
	[key: string]: GuardActionSchema | ActionHandler | boolean;
}

export interface GuardServiceSchema<S = ServiceSettingSchema> extends Partial<ServiceSchema<S>> {
	actions?: GuardServiceActionsSchema;
	authToken: string;
}
