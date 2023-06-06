const router = require("express").Router();
const { body } = require("express-validator");

const AuthController = require("../controllers/auth.controller");
const Validator = require("../utils/validator");
const UserService = require("../services/user.service");

const ensureAuthenticated = require("../middlewares/ensureAuthenticated.mdw");

// Luồng sự kiện chính: Đăng nhập với số điện thoại
// 1. Người dùng nhập số điện thoại
// 2. Gửi mã OTP đến số điện thoại
// 3a. Nếu số điện thoại chưa được đăng ký thì chuyển hướng vô trang nhâp mật khẩu mới
// 4a. Người dùng nhập mật khẩu
// 5a. Lưu mật khẩu mới vào db
// 6a. Nhập thông tin cá nhân: tên...
// 7a. Lưu thông tin cá nhân vào db
// 8a. Đăng nhập thành công
// 9a. Gửi trả jwt token

// 3b. Nếu số điện thoại đã được đăng ký thì chuyển hướng vô trang nhập mật khẩu
// 4b. Người dùng nhập mật khẩu
// 5b. Kiểm tra mật khẩu
// 6b. Đăng nhập thành công
// 7b. Gửi trả jwt token

router.post(
  "/verify-otp",
  [
    body("phone_number")
      .trim()
      .isMobilePhone()
      .bail()
      .custom(async (value) => {
        try {
          const user = await UserService.getUserByPhoneNumber(value);
          if (!user) {
            return Promise.reject("Phone number not exist");
          }
        } catch ({ name, message }) {
          return Promise.reject(
            "Error occurred while validating phone number: " + message
          );
        }
      }),
  ],
  Validator.validate,
  AuthController.verifyOTP
);

router.post(
  "/login-with-phone",
  [
    body("phone_number")
      .trim()
      .isMobilePhone()
      .bail()
      .custom(async (value) => {
        try {
          const user = await UserService.getUserByPhoneNumber(value);
          if (!user) {
            return Promise.reject("Phone number not exist");
          }
        } catch ({ name, message }) {
          return Promise.reject(
            "Error occurred while validating phone number: " + message
          );
        }
      }),
    body("password").isNumeric().isLength({ min: 6, max: 6 }),
  ],
  Validator.validate,
  AuthController.loginWithPhone
);

router.get("/logged-user", ensureAuthenticated, async (req, res) => {
  const id = req.user.id;
  return res.json(await UserService.getUserInfo(id));
});

router.get("/is-logged-in", ensureAuthenticated, (req, res) => {
  res.json({ isLoggedIn: true });
});

// router.post(
//   "/signup",
//   [
//     body("phone_number").trim().isMobilePhone(),
//     body("password").trim().isLength({ min: 6, max: 25 }),
//     body("email")
//       .trim()
//       .custom(async (value) => {
//         try {
//           const user = await UserService.getUserByEmail(value);
//           if (user) {
//             return Promise.reject("E-mail already in use");
//           }
//         } catch (error) {
//           return Promise.reject("Error occurred while validating e-mail");
//         }
//       }),
//   ],
//   Validation.validate,
//   AuthController.signup
// );

// router.post(
//   "/reset-password",
//   [
//     body("email").trim().isEmail(),
//     body("email")
//       .trim()
//       .custom(async (value) => {
//         try {
//           console.log(value);
//           const user = await UserService.getUserByEmail(value);
//           if (!user) {
//             return Promise.reject("E-mail not exist");
//           }
//         } catch (error) {
//           return Promise.reject("Error occurred while validating e-mail");
//         }
//       }),
//   ],
//   Validation.validate,
//   AuthController.resetPassword
// );

module.exports = router;
