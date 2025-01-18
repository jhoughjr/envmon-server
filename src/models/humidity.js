const { DataTypes } = require("sequelize");

  module.exports = (sequelize) => {
    return sequelize.define("Humidity", {
      value: {
        type: DataTypes.FLOAT,
        allowNull: false
      },
      timestamp: {
        type: DataTypes.DATE,
        defaultValue: DataTypes.NOW
      }
    });
  };
