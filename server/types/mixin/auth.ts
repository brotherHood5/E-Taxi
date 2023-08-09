import type { Service, ServiceSchema, ServiceSettingSchema } from "moleculer";
import type { DbAdapter, MoleculerDbMethods } from "moleculer-db";
import type MongoDbAdapter from "moleculer-db-adapter-mongo";
import type { IUserBase, UserRole } from "../common/user";

export interface AuthServiceSettings extends ServiceSettingSchema {
	rest?: string;
	accessTokenSecret: string;
	accessTokenExpiry: string;
	refreshTokenExpiry: number;
	otpExpireMin: number;
}

export interface AuthThis extends Service<AuthServiceSettings>, MoleculerDbMethods {
	adapter: DbAdapter | MongoDbAdapter;
}

export interface AuthMixinMethods {
	generateOTP(): string;

	cacheOtp(this: AuthThis, phoneNumber: string, otp: string): Promise<any>;

	verifyOtp(this: AuthThis, phoneNumber: string, otp: string): Promise<boolean>;
	/**
	 * Generate a hashed password
	 *
	 * @param {String} password plain text password
	 * @return {String} hashed password
	 */
	hashPassword(password: string): string;
	/**
	 * Verify a hashed password
	 *
	 * @param {String} password plain text password
	 * @param {String} hash hashed password
	 * @return {Boolean} true if password is correct
	 */
	verifyPassword(this: AuthThis, password: string, hash: string): boolean;

	/**
	 * Generate JWT token from user entity
	 * @param user user entity
	 * @returns {string | undefined} JWT token string
	 */
	generateAccessToken(this: AuthThis, user: IUserBase): Promise<string | undefined>;
}

export type AuthMixinSchema = Partial<ServiceSchema> & {
	methods: AuthMixinMethods;
};

export interface AuthLoginParams {
	phoneNumber: string;
	password: string;
}

export type AuthSignupParams = AuthLoginParams;

export interface AuthRefreshTokenParams {
	refreshToken: string;
}

export interface AuthVerifyOtpParams {
	phoneNumber: string;
	otp: string;
}

export interface AuthResendOtpParams {
	phoneNumber: string;
}

export interface AuthResolveTokenParams {
	token: string;
}

export interface AuthValidateRoleParams {
	roles: UserRole[];
}
