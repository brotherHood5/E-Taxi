const nodeMailer = require("nodemailer");

const sendToMail = async (email, password) => {
    const transporter = await nodeMailer.createTransport({
        service: "Gmail",
        auth: {
            user: "tripbloghelper@gmail.com",
            pass: "twkxakndyhdcgxlz",
        },
    });

    const mailOptions = await {
        from: "tripbloghelper@gmail.com",
        to: email,
        subject: "Reset password",
        text: `this is new password: ${password}`, // link này sẽ được thay thế bằng link của trang web
    };

    return new Promise((resolve, reject) => {
        transporter.sendMail(mailOptions, function (error, info) {
            if (error) {
                reject(error);
            } else {
                resolve(info);
            }
        });
    });
};

module.exports = {
    sendToMail,
};
