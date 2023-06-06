// const { DataTypes } = require("sequelize");
// const bcrypt = require("bcrypt");

// const sequelize = require("../config");
// const Converter = require("../utils/converter");

// const encryptPassword = function (password) {
//   const salt = bcrypt.genSaltSync(12);
//   const hash = bcrypt.hashSync(password, salt);
//   return hash;
// };

// const User = sequelize.define(
//   "User",
//   {
//     id: {
//       type: DataTypes.INTEGER,
//       autoIncrement: true,
//       primaryKey: true,
//       allowNull: false,
//     },
//     phone_number: {
//       type: DataTypes.STRING,
//       unique: true,
//       allowNull: false,
//     },
//     password: {
//       type: DataTypes.STRING,
//       allowNull: true,
//       defaultValue: null,
//     },
//     name: {
//       type: DataTypes.STRING,
//       allowNull: false,
//     },
//     name_non_accent: {
//       type: DataTypes.STRING,
//     },
//     avatar: {
//       type: DataTypes.STRING,
//       defaultValue:
//         "https://res.cloudinary.com/dkzlalahi/image/upload/v1678277295/default_male_avatar.jpg",
//     },
//   },
//   {
//     tableName: "users",
//     hooks: {
//       beforeCreate: async (user) => {
//         user.name_non_accent = Converter.toLowerCaseNonAccentVietnamese(
//           user.name
//         );
//       },
//       beforeUpdate: async (user) => {
//         user.name_non_accent = Converter.toLowerCaseNonAccentVietnamese(
//           user.name
//         );
//       },
//     },
//   }
// );

// User.prototype.checkPassword = function (plainPass, hashPass) {
//   return bcrypt.compareSync(plainPass, hashPass);
// };

// module.exports = User;
