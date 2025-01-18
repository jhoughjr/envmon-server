const { Humidity } = require("../models");
  const { Op } = require("sequelize");
  const wsManager = require("../managers/wsConnectionManager");

  exports.create = async (req, res) => {
    try {
      const reading = await Humidity.create(req.body);
      wsManager.broadcast({ type: "humidity", data: reading });
      res.status(201).json(reading);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

  exports.getLatest = async (req, res) => {
    try {
      const reading = await Humidity.findOne({
        order: [["timestamp", "DESC"]]
      });
      res.json(reading);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };

  exports.getRange = async (req, res) => {
    const { start, end } = req.query;
    try {
      const readings = await Humidity.findAll({
        where: {
          timestamp: {
            [Op.between]: [start, end]
          }
        },
        order: [["timestamp", "ASC"]]
      });
      res.json(readings);
    } catch (error) {
      res.status(500).json({ error: error.message });
    }
  };
