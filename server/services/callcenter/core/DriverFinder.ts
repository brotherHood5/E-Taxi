import type { IBooking, IDriver } from "../../../entities";
import { createTestDrivers } from "../../../helpers/seed";
import DriverSeatFinderFactory from "./class/SeatStrategies/DriverSeatFinderFactory";

class DriverFinder {
	findDriver(drivers: Set<IDriver>, request: IBooking): IDriver[] {
		const strategy = DriverSeatFinderFactory.createStrategy(request.vehicleType);
		const seatFilter = strategy.findDriver(Array.from(drivers));
		return seatFilter;
	}
}

export default DriverFinder;
