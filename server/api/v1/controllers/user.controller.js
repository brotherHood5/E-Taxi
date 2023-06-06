const UserService = require("../services/user.service");

const getUserInfo = async (req, res) => {
  const user = await UserService.getUserInfo(req.params.user_id);
  return res.jsonSuccess(user);
};



const updateUser = async (req, res) => {};

module.exports = {
  getUserInfo,
  updateUser,
};
