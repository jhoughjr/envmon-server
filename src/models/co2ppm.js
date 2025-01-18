const { DataTypes } = require("sequelize");

  module.exports = (sequelize) => {
    return sequelize.define("Co2ppm", {
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
