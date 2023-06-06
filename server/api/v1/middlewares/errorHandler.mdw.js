const { ErrorResponse } = require("../models/response.model");

const errorHandler = (err, req, res, next) => {
  if (err instanceof Error) {
    return res.jsonError(new ErrorResponse(err));
  }

  return res.jsonError(err);
};

module.exports = errorHandler;
