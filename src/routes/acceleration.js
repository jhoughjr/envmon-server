const express = require("express");
  const router = express.Router();
  const controller = require("../controllers/acceleration");

  router.post("/", controller.create);
  router.get("/latest", controller.getLatest);
  router.get("/range", controller.getRange);

  module.exports = router;
