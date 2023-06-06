const ResponseStatus = {
  Success: "success",
  Failure: "failure",
  Error: "error",
};

class Response {
  constructor() {
    this.status = null;
  }
}

class SuccessResponse extends Response {
  constructor(res) {
    super();
    this.status_code = res.status_code || 200;
    this.status = ResponseStatus.Success;
    this.data = res.data || undefined;
  }
}

class FailureResponse extends Response {
  constructor(res) {
    super();
    this.status_code = res.status_code || 200;
    this.status = ResponseStatus.Failure;
    this.message = res.message || undefined;
  }
}

class ErrorResponse extends Response {
  constructor(error) {
    super();
    this.status_code = error.status_code || 500;
    this.status = ResponseStatus.Error;
    this.message = error.message || undefined;
  }

  static fromError(error) {
    return new ErrorResponse(error);
  }
}

class ValidationErrorResponse extends ErrorResponse {
  constructor(error) {
    super(error);
    this.message = "Validation Errors";
    this.errors = error.errors || undefined;
  }
}

module.exports = {
  SuccessResponse,
  FailureResponse,
  ErrorResponse,
  ValidationErrorResponse,
};
