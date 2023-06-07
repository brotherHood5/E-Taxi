const passport = require("passport");
const passportJWT = require("passport-jwt");
const ExtractJWT = passportJWT.ExtractJwt;
const JWTStrategy = passportJWT.Strategy;
const UserService = require("../services/user.service");

require("dotenv").config();

var opts = {
  jwtFromRequest: ExtractJWT.fromAuthHeaderAsBearerToken(),
  secretOrKey: process.env.JWT_SECRET,
};

passport.use(
  new JWTStrategy(opts, function verify(jwtPayload, done) {
    return UserService.getUserInfo(jwtPayload.id)
      .then((user) => {
        return done(null, user);
      })
      .catch((err) => {
        return done(err);
      });
  })
);

const ensureAuthenticated = passport.authenticate("jwt", {
  session: false,
});

module.exports = ensureAuthenticated;
