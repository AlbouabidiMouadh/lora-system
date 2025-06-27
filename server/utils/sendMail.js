const nodemailer = require('nodemailer');
require('dotenv').config();


// Gmail Provider
// const transporter = nodemailer.createTransport({
  // service: 'Gmail',
  // host: 'smtp.gmail.com',
  // port: 587,
  // secure: false, // false for port 587 (uses STARTTLS); true for port 465 (SSL)
  // auth: {
    // user: process.env.GMAIL_USER,
    // pass: process.env.GMAIL_PASS,
  // },
  // pool: true,
// });


// SendinBlue Porvider
const transporter = nodemailer.createTransport({
  service: 'SendinBlue',
  auth: {
    user: "dev.chouaieb@gmail.com",
    pass: "z7XwGQ6SVg0IyNYt",
  },
});

transporter.verify((error, success) => {
  if (error) {
    console.error('SMTP configuration error:', error);
  } else {
    console.log('SMTP server is ready to send emails');
  }
});

/**
 * Sends an email using Nodemailer with SendinBlue
 * @param {Object} options - Email options
 * @param {string} options.to - Recipient email address
 * @param {string} options.subject - Email subject
 * @param {string} [options.text] - Plain text content
 * @param {string} [options.html] - HTML content
 * @returns {Promise<void>}
 * @throws {Error} If email sending fails
 */
const sendEmail = async (options) => {
  try {
    // Validate input
    if (!options.to || !options.subject || (!options.text && !options.html)) {
      throw new Error('Missing required email fields: to, subject, or content');
    }

    // Define email options
    const message = {
      from: 'agriwise@gmail.com',
      to: options.to,
      subject: options.subject,
      text: options.text || undefined, 
      html: options.html || undefined, 
    };

    // Send email
    const info = await transporter.sendMail(message);

    if (process.env.NODE_ENV !== 'production') {
      console.log('Message sent: %s', info.messageId);
    }
  } catch (error) {
    console.error('Error sending email:', error);
    throw new Error('Failed to send email: ' + error.message);
  }
};

module.exports = sendEmail;