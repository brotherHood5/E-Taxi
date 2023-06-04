const errorHandler = (err, req, res, next) => {
  console.log("Error Handler Middleware");
  return res.jsonError(err);
};

module.exports = errorHandler;
