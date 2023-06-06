const { ValidationError } = require("sequelize");
const jwt = require("jsonwebtoken");
const AuthService = require("../services/auth.service");
const UserService = require("../services/user.service");
const { ErrorResponse, FailureResponse } = require("../models/response.model");

const loginWithPhone = async (req, res, next) => {
  const { phone_number, password } = req.body;
  try {
    // TODO: Implement login with phone number
    // login with phone number and password
    const user = await UserService.getUserByPhoneNumber(phone_number);

    if (!user.verifyPassword(password)) {
      return res.jsonFailure("Password incorrect");
    }

    const token = jwt.sign(
      { id: user.id, phone_number: user.phoneNumber },
      process.env.JWT_SECRET,
      {
        expiresIn: process.env.JWT_EXPIRES_IN,
      }
    );

    return res.jsonSuccess({ token, user });
  } catch (error) {
    next(new ErrorResponse(error));
  }
};

const verifyOTP = async (req, res, next) => {
  const { phone_number } = req.body;
  try {
    // TODO: Implement send otp to phone number then save phone number to db
    // Create new user with phone number
    // send otp
    // save phone number to db
  } catch (error) {
    next(new ErrorResponse(error));
  }
};

const finishSignup = async (req, res, next) => {
  const { phone_number, password, name } = req.body;
  try {
    // TODO: Implement login with phone number
    // next step after verify phone number (must be verified)
    // sign up with phone number and password
    // this step will create a new user with phone number and password
  } catch (error) {
    next(new ErrorResponse(error));
  }
};

// const login = async (req, res) => {
//   const { email, password } = req.body;

//   try {
//     let user = await UserService.getUserByEmail(email);
//     if (!user) {
//       return res.json(ResponseType.Failure("E-mail or password incorrect"));
//     }
//     if (!user.checkPassword(password, user.password)) {
//       return res.json(ResponseType.Failure("E-mail or password incorrect"));
//     }

//     const token = jwt.sign(
//       { id: user.id, email: user.email },
//       process.env.JWT_SECRET,
//       {
//         expiresIn: process.env.JWT_EXPIRES_IN,
//       }
//     );

//     user = user.toJSON();
//     delete user.password;
//     delete user.createdAt;
//     delete user.updatedAt;
//     delete user.tokens;

//     return res.json(ResponseType.Success({ token, user }));
//   } catch (error) {
//     if (error instanceof ValidationError) {
//       return res.json(
//         ResponseType.Error({
//           name: error.name,
//           msg: error.errors[0].message,
//         })
//       );
//     }
//     return res.json(ResponseType.Error(error.message));
//   }
// };

// const resetPassword = async (req, res) => {
//   const { email } = req.body;
//   try {
//     const user = await AuthService.resetPassword(email);
//     res.json(ResponseType.Success(user));
//   } catch (error) {
//     if (error instanceof ValidationError) {
//       return res.json(
//         ResponseType.Error({
//           name: error.name,
//           msg: error.errors[0].message,
//         })
//       );
//     }
//     return res.json(ResponseType.Error(error.message));
//   }
// };

module.exports = {
  loginWithPhone,
  verifyOTP,
};
