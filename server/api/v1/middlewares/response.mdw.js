const {
  SuccessResponse,
  FailureResponse,
  ErrorResponse,
  ValidationErrorResponse,
} = require("../models/response.model");

module.exports = function (req, res, next) {
  res.jsonSuccess = function (data, status_code = 200) {
    const response = new SuccessResponse({ data, status_code });
    res.status(response.status_code);
    response.status_code = undefined;
    return res.json(response);
  };

  res.jsonFailure = function (message, status_code = 500) {
    const response = new FailureResponse({ message, status_code });
    res.status(response.status_code);
    response.status_code = undefined;
    return res.json(response);
  };

  res.jsonError = function (error) {
    res.status(error.status_code || 500);
    error.status_code = undefined;
    return res.json(error);
  };

  next();
};
