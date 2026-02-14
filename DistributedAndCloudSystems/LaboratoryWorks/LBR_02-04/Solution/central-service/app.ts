import express from 'express';
import axios from 'axios';
import log, {LogLevel} from "./logger/logger";
import {pushDataToTerritorialServices, replicateData, syncTimeWithServices} from "./utils/utils";
import Measurement from "./db/model";
import sequelize from "./db/db";

const app = express();
const SERVICE_1_URL = 'http://localhost:3001';
const SERVICE_2_URL = 'http://localhost:3002';

app.get('/poll', async (req, res) => {
    try {
        const [data1, data2] = await Promise.all([
            axios.get(`${SERVICE_1_URL}/measurements`),
            axios.get(`${SERVICE_2_URL}/measurements`)
        ]);

        const receivedData = {
            service1: data1.data,
            service2: data2.data
        };
        log('Received data from web-services', LogLevel.REQUEST);
        res.json(receivedData);
    } catch (error) {
        log(`Service(s) is not available`, LogLevel.ERROR);
        res.status(400).json({ error: "Service(s) is not available" });
    }
});

app.get('/central-data', async (req, res) => {
    log('GET /central-data', LogLevel.REQUEST);
    try {
        const measurements = await Measurement.findAll();
        res.json(measurements);
    } catch (error) {
        log(`Failed to retrieve data: \n${error}`, LogLevel.ERROR);
        res.status(500).json({ error: 'Failed to retrieve data' });
    }
});

setInterval(async () => syncTimeWithServices(`${SERVICE_1_URL}/sync-time`, `${SERVICE_2_URL}/sync-time`), 15000);
setInterval(async () => replicateData(`${SERVICE_1_URL}/measurements`, `${SERVICE_2_URL}/measurements`), 10000);
setInterval(async () => pushDataToTerritorialServices(`${SERVICE_1_URL}/measurements`, `${SERVICE_2_URL}/measurements`), 90000);

sequelize.sync().then(() => {
    app.listen(3000, () => {
        console.log('Central service is running at http://localhost:3000');
    });
});
