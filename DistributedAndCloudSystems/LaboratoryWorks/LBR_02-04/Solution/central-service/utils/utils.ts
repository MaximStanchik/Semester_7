import axios from "axios";
import log, {LogLevel} from "../logger/logger";
import Measurement from "../db/model";

export const syncTimeWithServices = async (service1Url: string, service2Url: string) => {
    const centralTime = new Date().toISOString();

    try {
        await Promise.all([
            axios.post(service1Url, { centralTime }),
            axios.post(service2Url, { centralTime })
        ]);
        log(`Time synchronized with services at ${centralTime}`);
    } catch (error) {
        log(`Failed to sync time with services: \n${error}`, LogLevel.ERROR);
    }
};

export const replicateData = async (service1Url: string, service2Url: string) => {
    try {
        log('Starting data replication');

        const [service1Data, service2Data] = await Promise.all([
            axios.get(service1Url),
            axios.get(service2Url)
        ]);

        const allData = [
            ...service1Data.data.map((d: Omit<Measurement, "source">) => ({ ...d, source: 'Service 1' })),
            ...service2Data.data.map((d: Omit<Measurement, "source">) => ({ ...d, source: 'Service 2' }))
        ];

        await Measurement.bulkCreate(allData, {updateOnDuplicate: ['channel', 'value']});
        log('Data replication completed successfully');

    } catch (error) {
        log(`Data replication failed: \n${error}`, LogLevel.ERROR);
    }
};

export const pushDataToTerritorialServices = async (service1Url: string, service2Url: string) => {
    try {
        log('Starting push replication to territorial services');

        const dataToPush = await Measurement.findAll({ limit: 5, order: [['updatedAt', 'DESC']] });

        await Promise.all([
            axios.put(service1Url, { data: dataToPush }),
            axios.put(service2Url, { data: dataToPush })
        ]);

        log('Push replication to territorial services completed successfully');
    } catch (error) {
        log(`Push replication failed: \n${error}`, LogLevel.ERROR);
    }
};
