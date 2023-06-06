const router = require("express").Router();

const ensureAuthenticated = require("./middlewares/ensureAuthenticated.mdw");

require("./models");

router.use("/auth", require("./routes/auth"));
router.use("/user", ensureAuthenticated, require("./routes/user"));

module.exports = router;
