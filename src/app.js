require("dotenv").config();
const express = require("express");
const cors = require("cors");
const helmet = require("helmet");
const { sequelize } = require("./models");
const wsManager = require("./managers/wsConnectionManager");

const app = express();

app.use(helmet());
app.use(cors());
app.use(express.json());

// Routes
app.use("/api/temperature", require("./routes/temperature"));
app.use("/api/humidity", require("./routes/humidity"));
app.use("/api/co2", require("./routes/co2"));
app.use("/api/acceleration", require("./routes/acceleration"));

const PORT = process.env.PORT || 8080;

const server = app.listen(PORT, async () => {
  try {
    await sequelize.authenticate();
    console.log("Database connection established");
    console.log(`Server running on port ${PORT}`);
  } catch (error) {
    console.error("Unable to connect to database:", error);
  }
});

wsManager.initialize(server);

module.exports = server;
