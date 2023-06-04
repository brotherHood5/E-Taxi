const express = require("express");
const router = express.Router();
const { body } = require("express-validator");

const UserController = require("../controllers/user.controller");
const UserService = require("../services/user.service");
const Validator = require("../utils/validator");
const multer = require("../utils/multer");

//GET /:user_id: Lấy thông tin cá nhân
router.get("/:user_id", UserController.getUserInfo);

//PATCH /:user_id/update: Cập nhật thông tin cá nhân
// router.patch(
//   "/:user_id/update",
//   multer.single("avatar"),
//   Validator.validate,
//   UserController.updateUser
// );

module.exports = router;
