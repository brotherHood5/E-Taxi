import type { JwtPayload } from "jsonwebtoken";
import { sign, verify } from "jsonwebtoken";

export const generateJWT = (
	user: object,
	secret: string,
	expiry: string,
): Promise<string | undefined> =>
	new Promise((resolve, reject) => {
		sign({ user }, secret, { algorithm: "HS256", expiresIn: expiry }, (err, token) => {
			if (err) {
				return reject(err);
			}
			return resolve(token);
		});
	});

export const verifyJWT = (
	token: string,
	secret: string,
): Promise<string | JwtPayload | undefined> =>
	new Promise((resolve, reject) => {
		verify(token, secret, (err, decoded) => {
			if (err) {
				return reject(err);
			}
			return resolve(decoded);
		});
	});
