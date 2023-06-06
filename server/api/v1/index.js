const router = require("express").Router();

const ensureAuthenticated = require("./middlewares/ensureAuthenticated.mdw");

require("./models");

router.use("/ping", (req, res) => {
  return res.json({ message: "Pong", time: Date.now() });
});
router.use("/auth", require("./routes/auth"));
router.use("/user", ensureAuthenticated, require("./routes/user"));

module.exports = router;
