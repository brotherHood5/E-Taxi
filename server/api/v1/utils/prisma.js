const { PrismaClient } = require("@prisma/client");
const bcrypt = require("bcrypt");

const prisma = new PrismaClient();

const xprisma = prisma.$extends({
  client: {
    $exclude(user, keys) {
      for (let key of keys) {
        delete user[key];
      }
      return user;
    },
  },
  model: {
    user: {
      async findUserByPhoneNumber(phone_number) {
        return await this.findUnique({ where: { phoneNumber: phone_number } });
      },
    },
  },
  result: {
    user: {
      verifyPassword: {
        needs: { password: true },
        compute(user) {
          return (password) => {
            return bcrypt.compareSync(password, user.password);
          };
        },
      },
      updatePassword: {
        needs: { id: true },
        compute: (user) => {
          return () => {
            const salt = bcrypt.genSaltSync(12);
            const hash = bcrypt.hashSync(password, salt);
            this.update({
              where: { id: user.id },
              data: { password: hash },
            });
          };
        },
      },
    },
  },
});

module.exports = xprisma;
