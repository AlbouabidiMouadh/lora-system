const User = require("../models/User");
const bcrypt = require("bcryptjs");
const crypto = require("crypto");
const { sendResponse, generateToken } = require("../utils/helpers");

/**
 * @function register
 * @description Registers a new user, hashes the password, stores user in the database, and returns a JWT token.
 * @route POST /api/auth/register
 * @access Public
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success, message, token, and user data
 */
exports.register = async (req, res) => {
  try {
    const { name, email, password, phoneNumber } = req.body;

    const exists = await User.findOne({ email });
    if (exists)
      return sendResponse(res, 400, false, "Email already registered");

    const user = new User({ name, email, password, phoneNumber });
    await user.save();

    const token = generateToken(user._id);

    // Send account creation confirmation email
    const message = `
      <h1>Welcome to Our Platform, ${user.name}!</h1>
      <p>Your account has been successfully created.</p>
      <p>If this wasn’t you, please contact our support immediately.</p>
    `;

    try {
      await sendEmail({
        to: user.email,
        subject: "Account Created Successfully",
        html: message,
      });
    } catch (err) {
      console.error("Email send failed:", err.message);
      // Optionally log, but don’t fail registration if email fails
    }

    sendResponse(res, 201, true, "Registration successful", { token, user });
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};
/**
 * @function login
 * @description Authenticates a user with email and password, generates and returns a JWT token on success.
 * @route POST /api/auth/login
 * @access Public
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success, message, token, and user data
 */
exports.login = async (req, res) => {
  try {
    const { email, password } = req.body;

    const user = await User.findOne({ email });
    if (!user) return sendResponse(res, 401, false, "Invalid credentials");

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return sendResponse(res, 401, false, "Invalid credentials");

    const token = generateToken(user._id);
    sendResponse(res, 200, true, "Login successful", { token, user });
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function updatePassword
 * @description Updates the user's password after verifying the current password.
 * @route PUT /api/auth/updatepassword
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success, message, and new token
 */
exports.updatePassword = async (req, res) => {
  try {
    const user = await User.findById(req.user.id);

    // Verify current password
    const isMatch = await user.matchPassword(req.body.currentPassword);
    if (!isMatch) {
      return sendResponse(res, 401, false, "Current password is incorrect");
    }

    // Update password
    user.password = req.body.newPassword;
    await user.save();

    // Generate new token
    const token = generateToken(user._id);
    sendResponse(res, 200, true, "Password updated successfully", { token });
  } catch (err) {
    sendResponse(res, 500, false, "Error updating password");
  }
};

/**
 * @function forgotPassword
 * @description Generates a password reset token and sends a reset email to the user.
 * @route POST /api/auth/forgotpassword
 * @access Public
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success and message
 */
exports.forgotPassword = async (req, res) => {
  const { email } = req.body;

  try {
    const user = await User.findOne({ email });
    if (!user) {
      return sendResponse(res, 404, false, "No user found with this email");
    }

    // Generate reset token
    const resetToken = user.getResetPasswordToken();
    await user.save();

    // Create reset URL
    const resetUrl = `${process.env.APP_URL}/reset-password?resettoken=${resetToken}`;

    const message = `
      <h1>Password Reset Request</h1>
      <p>You have requested to reset your password.</p>
      <p>Please click the link below to reset your password:</p>
      <a href="${resetUrl}" 
         style="background-color: #4CAF50; color: white; padding: 12px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
         Reset My Password
      </a>
      <p>This link will expire in 10 minutes.</p>`;

    try {
      await sendEmail({
        to: user.email,
        subject: "Password Reset Request",
        html: message,
      });

      sendResponse(res, 200, true, "Reset email sent successfully");
    } catch (err) {
      user.resetPasswordToken = undefined;
      user.resetPasswordExpire = undefined;
      await user.save();
      sendResponse(res, 500, false, "Failed to send reset email");
    }
  } catch (err) {
    sendResponse(res, 500, false, "Error processing password reset request");
  }
};

/**
 * @function resetPassword
 * @description Resets the user's password using a valid reset token, verifies current password, and checks new password.
 * @route PUT /api/auth/resetpassword/:resettoken
 * @access Public
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success and message
 */
exports.resetPassword = async (req, res) => {
  // Hash the provided token
  const resetPasswordToken = crypto
    .createHash("sha256")
    .update(req.params.resettoken)
    .digest("hex");

  try {
    const user = await User.findOne({
      resetPasswordToken,
      resetPasswordExpire: { $gt: Date.now() },
    });

    if (!user) {
      return sendResponse(res, 400, false, "Invalid or expired token");
    }

    // Verify current password
    const isMatch = await user.matchPassword(req.query.currentPassword);
    if (!isMatch) {
      return sendResponse(res, 401, false, "Current password is incorrect");
    }

    // Check if new password is provided
    if (!req.query.newPassword) {
      return sendResponse(res, 400, false, "New password is required");
    }

    // Set new password and clear reset fields
    user.password = req.query.newPassword;
    user.resetPasswordToken = undefined;
    user.resetPasswordExpire = undefined;
    await user.save();

    sendResponse(res, 200, true, "Password reset successfully");
  } catch (err) {
    sendResponse(res, 500, false, "Error resetting password");
  }
};

/**
 * @function logout
 * @description Logs out the user by instructing the client to discard the JWT token.
 * @route POST /api/auth/logout
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success and message
 */
exports.logout = async (req, res) => {
  try {
    // Since JWT is stateless, no server-side invalidation is needed
    // Client should discard the token
    sendResponse(res, 200, true, "Logout successful");
  } catch (err) {
    sendResponse(res, 500, false, "Error logging out");
  }
};