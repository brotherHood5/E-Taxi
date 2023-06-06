const multer = require("multer");

// Multer config
const storage = multer.memoryStorage();
const limits = { fileSize: 1000 * 1000 * 4 };
const upload = multer({ storage, limits });

module.exports = upload;
