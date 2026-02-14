import log from "../logger/logger";
import Measurement from "./model";

const generateData = async () => {
    if (await Measurement.count() < 10) {
        for (let i = 1; i <= 10; i++) {
            const randomValue = Math.floor(Math.random() * 12);
            await Measurement.create({channel: `channel-${i}`, value: randomValue});
        }

        log('Data generation completed');
    }
};

export default generateData;