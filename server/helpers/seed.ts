import { fakerVI as faker } from "@faker-js/faker";
import _ from "lodash";
import type { AddressEntity, CustomerEntity, IDriver, StaffEntity } from "../entities";
import { VehicleType } from "../entities";
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

export function createTestDrivers(n = 10): IDriver[] {
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
			vehicleType: faker.helpers.enumValue(VehicleType),
		} as IDriver;
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
		vehicleType: faker.helpers.enumValue(VehicleType),
	} as IDriver);
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

export function createTestAddresses(n = 10): AddressEntity[] {
	return _.times(n, () => {
		const currentDate = faker.date.recent({ days: faker.number.int({ min: 1, max: 10 }) });
		return {
			homeNo: faker.location.streetAddress(),
			street: faker.location.street(),
			ward: faker.location.state(),
			district: faker.location.county(),
			city: faker.location.city(),
			lat: faker.location.latitude() || undefined,
			lon: faker.location.longitude() || undefined,
			createdAt: currentDate,
			updatedAt: faker.date.soon({
				days: faker.number.int({ min: 1, max: 10 }),
				refDate: currentDate,
			}),
		} as AddressEntity;
	});
}
