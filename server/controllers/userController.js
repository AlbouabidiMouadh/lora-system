const User = require("../models/User");
const { sendResponse } = require("../utils/helpers");

/**
 * @function createUser
 * @description Creates a new user with the data provided in the request body.
 * @route POST /api/users
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response containing the created user data
 */
exports.createUser = async (req, res) => {
  try {
    const user = new User(req.body);
    const savedUser = await user.save();
    sendResponse(res, 201, true, "User created successfully", savedUser);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getUsers
 * @description Retrieves all users from the database.
 * @route GET /api/users
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with an array of user objects
 */
exports.getUsers = async (req, res) => {
  try {
    const users = await User.find();
    sendResponse(res, 200, true, "Users fetched successfully", users);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function getUserById
 * @description Retrieves a single user by their ID.
 * @route GET /api/users/:id
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response containing user data or error message if not found
 */
exports.getUserById = async (req, res) => {
  try {
    const user = await User.findById(req.params.id);
    if (!user) {
      return sendResponse(res, 404, false, "User not found");
    }
    sendResponse(res, 200, true, "User fetched successfully", user);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function updateUser
 * @description Updates user data by ID with the data provided in the request body.
 * @route PUT /api/users/:id
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with updated user data or error message if not found
 */
exports.updateUser = async (req, res) => {
  try {
    const user = await User.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true,
    });
    if (!user) {
      return sendResponse(res, 404, false, "User not found");
    }
    sendResponse(res, 200, true, "User updated successfully", user);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function deleteUser
 * @description Deletes a user by their ID.
 * @route DELETE /api/users/:id
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response confirming deletion or error if user not found
 */
exports.deleteUser = async (req, res) => {
  try {
    const user = await User.findByIdAndDelete(req.params.id);
    if (!user) {
      return sendResponse(res, 404, false, "User not found");
    }
    sendResponse(res, 200, true, "User deleted successfully", null);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};
