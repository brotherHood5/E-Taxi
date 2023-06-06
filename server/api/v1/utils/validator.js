const { validationResult } = require("express-validator");
const { ValidationErrorResponse } = require("../models/response.model");

const validate = (req, res, next) => {
  const errors = validationResult(req);
  if (!errors.isEmpty()) {
    next(new ValidationErrorResponse({ errors: errors.array() }));
  }
  next();
};

module.exports = {
  validate,
};
