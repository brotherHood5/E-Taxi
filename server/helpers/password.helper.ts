import bcrypt from "bcryptjs";
import { Config } from "../common";

/**
 * Generate a hashed password
 *
 * @param {String} plainPassword
 * @return {String} hashed password
 */
export function hashPassword(plainPassword: string): string {
	const salt = bcrypt.genSaltSync(Config.SALT);
	return bcrypt.hashSync(plainPassword, salt);
}

/**
 * Verify a hashed password
 *
 * @param {String} hashedPassword
 * @param {String} plainPassword
 * @return {Boolean}
 */
export function verifyPassword(hashedPassword: string, plainPassword: string): boolean {
	return bcrypt.compareSync(plainPassword, hashedPassword);
}
