const { DataTypes } = require("sequelize");

  module.exports = (sequelize) => {
    return sequelize.define("Acceleration", {
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
