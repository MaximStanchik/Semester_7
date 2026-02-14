import express from 'express';
import sequelize from './db/db';
import Measurement from './db/model';
import log, {LogLevel} from "./logger/logger";
import generateData from "./db/init";

const app = express();
app.use(express.json());

let currentTime = new Date();

app.get('/measurements', async (req, res) => {
    const measurements = await Measurement.findAll();
    log(`GET: /measurements`, LogLevel.REQUEST);
    res.json(measurements);
});

app.post('/measurements', async (req, res) => {
    log(`POST: /measurements`, LogLevel.REQUEST);
    const { channel, value } = req.body;
    const measurement = await Measurement.create({ channel, value });
    res.json(measurement);
});


app.put('/measurements', async (req, res) => {
    log(`PUT: /measurements`, LogLevel.REQUEST);
    try {
        const { data } = req.body;

        for (const measurement of data) {
            await Measurement.upsert({
                id: measurement.id,
                channel: measurement.channel,
                value: measurement.value
            });
        }

        log('Data replicated from central service successfully');
        res.status(200).json({ message: 'Replication successful' });
    } catch (error) {
        log(`Replication failed: \n${error}`, LogLevel.ERROR);
        res.status(500).json({ error: 'Replication failed' });
    }
});

app.post('/sync-time', (req, res) => {
    const { centralTime } = req.body;
    if (centralTime) {
        currentTime = new Date(centralTime);
        log(`Time synchronized with central server: ${currentTime.toISOString()}`);
        res.status(200).send('Time synchronized successfully');
    } else {
        log('Failed to synchronize time: centralTime is missing', LogLevel.ERROR);
        res.status(400).send('Central time is required');
    }
});


sequelize.sync().then(async () => {
    await generateData();
    app.listen(3002, () => {
        console.log('Service 2 is running at http://localhost:3002');
    });
});
