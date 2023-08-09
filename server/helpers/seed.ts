import { fakerVI as faker } from "@faker-js/faker";
import _ from "lodash";
import type { CustomerEntity, DriverEntity, StaffEntity } from "../entities";
import { UserRole } from "../types/common";
import { hashPassword } from "./password.helper";

export function createTestCustomers(n = 10): CustomerEntity[] {
	const list = _.times(n - 1, () => {
		const currentDate = faker.date.recent({ days: faker.number.int({ min: 1, max: 10 }) });
		return {
			fullName: faker.person.fullName(),
			phoneNumber: faker.phone.number("09########"),
			passwordHash: hashPassword("Vinh1706!"),
			phoneNumberVerified: faker.datatype.boolean(0.9),
			enable: faker.datatype.boolean(1),
			active: faker.datatype.boolean(0.98),
			createdAt: currentDate,
			updatedAt: faker.date.soon({
				days: faker.number.int({ min: 1, max: 10 }),
				refDate: currentDate,
			}),
			roles: [UserRole.CUSTOMER],
		} as CustomerEntity;
	});
	list.push({
		fullName: "Dương Quang Vinh",
		phoneNumber: "0972360214",
		passwordHash: hashPassword("Vinh1706!"),
		phoneNumberVerified: true,
		enable: true,
		active: true,
		createdAt: new Date(),
		updatedAt: new Date(),
		roles: [UserRole.CUSTOMER],
	} as CustomerEntity);
	return list;
}

export function createTestDrivers(n = 10): DriverEntity[] {
	const list = _.times(n - 1, () => {
		const currentDate = faker.date.recent({ days: faker.number.int({ min: 1, max: 10 }) });
		return {
			fullName: faker.person.fullName(),
			phoneNumber: faker.phone.number("09########"),
			passwordHash: hashPassword("Vinh1706!"),
			phoneNumberVerified: faker.datatype.boolean(0.9),
			enable: faker.datatype.boolean(1),
			active: faker.datatype.boolean(0.98),
			createdAt: currentDate,
			updatedAt: faker.date.soon({
				days: faker.number.int({ min: 1, max: 10 }),
				refDate: currentDate,
			}),
			roles: [UserRole.DRIVER],
		} as DriverEntity;
	});
	list.push({
		fullName: "Dương Quang Vinh",
		phoneNumber: "0972360214",
		passwordHash: hashPassword("Vinh1706!"),
		phoneNumberVerified: true,
		enable: true,
		active: true,
		createdAt: new Date(),
		updatedAt: new Date(),
		roles: [UserRole.DRIVER],
	} as DriverEntity);
	return list;
}

export function createTestStaffs(n = 10): StaffEntity[] {
	const list = _.times(n - 1, (): StaffEntity => {
		const currentDate = faker.date.recent({ days: faker.number.int({ min: 1, max: 10 }) });
		return {
			fullName: faker.person.fullName(),
			username: faker.internet.userName(),
			passwordHash: hashPassword("Vinh1706!"),
			roles: [UserRole.STAFF],
			createdAt: currentDate,
			updatedAt: faker.date.soon({
				days: faker.number.int({ min: 1, max: 10 }),
				refDate: currentDate,
			}),
		};
	});
	list.push({
		fullName: "Dương Quang Vinh",
		username: "20127665",
		passwordHash: hashPassword("Vinh1706!"),
		createdAt: new Date(),
		updatedAt: new Date(),
		roles: [UserRole.STAFF],
	});
	return list;
}
