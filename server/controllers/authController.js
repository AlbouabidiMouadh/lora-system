const User = require('../models/User');
const bcrypt = require('bcryptjs');
const { sendResponse, generateToken } = require('../utils/helpers');

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
    const { name, email, password } = req.body;

    const exists = await User.findOne({ email });
    if (exists) return sendResponse(res, 400, false, 'Email already registered');

    const user = new User({ name, email, password });
    await user.save();

    const token = generateToken(user._id);
    sendResponse(res, 201, true, 'Registration successful', { token, user });
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
    if (!user) return sendResponse(res, 401, false, 'Invalid credentials');

    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) return sendResponse(res, 401, false, 'Invalid credentials');

    const token = generateToken(user._id);
    sendResponse(res, 200, true, 'Login successful', { token, user });
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};
