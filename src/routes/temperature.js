const express = require("express");
  const router = express.Router();
  const controller = require("../controllers/temperature");

  router.post("/", controller.create);
  router.get("/latest", controller.getLatest);
  router.get("/range", controller.getRange);

  module.exports = router;
