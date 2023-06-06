const cloudinary = require("cloudinary").v2;
const streamifier = require("streamifier");

// Configuration
cloudinary.config({
  cloud_name: process.env.CLOUD_NAME,
  api_key: process.env.API_KEY_CLOUD,
  api_secret: process.env.API_SECRET_CLOUD,
});

const upload = async (file, options) => {
  const res = await cloudinary.uploader.upload(file, options);
  return res.secure_url;
};

const uploadStream = async (stream, options) => {
  return new Promise((resolve, reject) => {
    const upload_stream = cloudinary.uploader.upload_stream(
      options,
      (err, res) => {
        if (err) {
          return reject(err);
        }

        resolve({
          url: res.secure_url,
          public_id: res.public_id,
        });
      }
    );
    streamifier.createReadStream(stream).pipe(upload_stream);
  });
};

const destroy = async (url, options) => {
  const regex = new RegExp("/v(?:d+/)?([^.]+)/*");
  const result = regex.exec(url);
  const public_id = result[1].split("/").slice(1).join("/");
  const res = await cloudinary.uploader.destroy(public_id, options);
  return res;
};

module.exports = {
  upload,
  uploadStream,
  destroy,
};
