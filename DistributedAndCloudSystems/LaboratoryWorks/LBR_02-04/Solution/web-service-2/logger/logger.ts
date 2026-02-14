export enum LogLevel {
    INFO = 'INFO',
    ERROR = 'ERROR',
    REQUEST = 'REQUEST',
}

const log = (message: string, type: LogLevel = LogLevel.INFO) => {
    const timestamp = new Date().toISOString();
    switch (type) {
        case LogLevel.INFO:
            console.log("\x1b[32m", `[${timestamp}] [${type}] ${message}`);
            break;
        case LogLevel.ERROR:
            console.error("\x1b[31m", `[${timestamp}] [${type}] ${message}`);
            break;
        case LogLevel.REQUEST:
            console.log("\x1b[34m", `[${timestamp}] [${type}] ${message}`);
            break;
    }
};

export default log;
