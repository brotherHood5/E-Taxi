const nodeMailer = require("../utils/nodemailer");
const UserService = require("../services/user.service");

const resetPassword = async (email) => {
  // const password = Math.random().toString(36).slice(-8);
  // const sentNewPassword = await nodeMailer.sendToMail(email, password);
  // console.log(sentNewPassword);
  // if (sentNewPassword) {
  //     UserService.updatePassword(email, password);
  // }
};

module.exports = {
  resetPassword,
};
