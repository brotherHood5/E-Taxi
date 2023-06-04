const prisma = require("../utils/prisma");

const defaultExcludeFields = ["password"];

const createUser = async (user) => {
  return await prisma.user.create({
    data: user,
  });
};

const getUserByPhoneNumber = async (phone_number) => {
  const user = await prisma.user.findUserByPhoneNumber(phone_number);
  return user;
};

const getUserInfo = async (user_id, excludeFields = defaultExcludeFields) => {
  return prisma.$exclude(
    await prisma.user.findUnique({ where: { id: user_id } }),
    excludeFields
  );
};

const updateUser = async () => {};

module.exports = {
  createUser,
  updateUser,
  getUserInfo,
  getUserByPhoneNumber,
};
