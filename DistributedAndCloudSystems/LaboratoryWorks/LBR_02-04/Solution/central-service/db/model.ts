import {DataTypes, Model} from 'sequelize';
import {v4 as uuidv4} from 'uuid';
import sequelize from './db';

class Measurement extends Model {
}

Measurement.init({
    id: {
        type: DataTypes.UUID,
        defaultValue: uuidv4,
        primaryKey: true,
    },
    channel: {
        type: DataTypes.STRING,
        allowNull: false,
    },
    value: {
        type: DataTypes.FLOAT,
        allowNull: false,
    },
    source: {
        type: DataTypes.STRING,
        allowNull: false
    }
}, {
    sequelize,
    modelName: 'Measurement'
});

export default Measurement;
