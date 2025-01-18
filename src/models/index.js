const { Sequelize } = require("sequelize");
const config = require("../../config/config.js")[process.env.NODE_ENV || "development"];

const sequelize = new Sequelize(config.database, config.username, config.password, {
  host: config.host,
  dialect: config.dialect
});

const models = {
  Temperature: require("./temperature")(sequelize),
  Humidity: require("./humidity")(sequelize),
  CO2ppm: require("./co2ppm")(sequelize),
  Acceleration: require("./acceleration")(sequelize),
};

module.exports = { sequelize, ...models };
