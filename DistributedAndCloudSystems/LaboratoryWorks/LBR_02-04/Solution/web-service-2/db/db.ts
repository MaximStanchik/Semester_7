import { Sequelize } from 'sequelize';

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database2.sqlite',
    logging: false
});

export default sequelize;
