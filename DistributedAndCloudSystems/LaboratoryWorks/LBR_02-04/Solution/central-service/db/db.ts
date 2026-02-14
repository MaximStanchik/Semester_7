import { Sequelize } from 'sequelize';

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database-central.sqlite',
    logging: false,
});

export default sequelize;
