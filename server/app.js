const express = require("express");
const path = require("path");
const cookieParser = require("cookie-parser");
const logger = require("morgan");
const cors = require("cors");
const helmet = require("helmet");
const compression = require("compression");
const app = express();

const errorHandler = require("./api/v1/middlewares/errorHandler.mdw");
const responseHandler = require("./api/v1/middlewares/response.mdw");

app.use(logger("dev"));
app.use(express.json());
app.use(express.urlencoded({ extended: false }));
app.use(cors());
app.use(cookieParser());
app.use(express.static(path.join(__dirname, "public")));
app.use(compression());
app.use(helmet());

// Middleware
app.use(responseHandler);

// Routes
app.use("/api/v1/", require("./api/v1"));

// Error handler
app.use(errorHandler);

module.exports = app;
