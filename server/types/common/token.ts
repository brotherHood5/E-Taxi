import type { Service, ServiceMethods, ServiceSettingSchema } from "moleculer";
import type { DbServiceSettings } from "moleculer-db";
import type { RefreshToken } from "../../entities";
import type { GuardServiceSchema, ObjectId } from "./interfaces";

interface TokenSettings extends DbServiceSettings, ServiceSettingSchema {
	rest?: string;
}

interface TokenMethods extends ServiceMethods {
	/**
	 * Check refresh token expired
	 * @param refreshToken refresh token
	 * @returns true if refresh token expired
	 * @returns false if refresh token not expired
	 */
	checkExpired(this: TokenThis, refreshToken: RefreshToken): boolean;

	/**
	 * Generate refresh token
	 * @param {ObjectId} userId user entity
	 * @param {number} ttl expires duration time
	 * @returns {RefreshToken} refresh token
	 */
	generateRefreshToken(this: TokenThis, userId: ObjectId, ttl: number): RefreshToken;
}

export type TokenThis = Service<TokenSettings>;

export type TokenServiceSchema = GuardServiceSchema<TokenSettings> & { methods: TokenMethods };

// Params
export interface TokenGenerateParams {
	userId: ObjectId;
	ttl: number;
}

export interface TokenVerifyParams {
	refreshToken: string;
}
