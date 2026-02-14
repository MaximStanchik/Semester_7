import { Sequelize } from 'sequelize';

const sequelize = new Sequelize({
    dialect: 'sqlite',
    storage: './database1.sqlite',
    logging: false,
});

export default sequelize;
