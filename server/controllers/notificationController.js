const Notification = require('../models/Notification');
const Pump = require('../models/Pump');
const { sendResponse } = require('../utils/helpers');

/**
 * @function createNotification
 * @description Creates a new notification for a user, typically triggered by pump events.
 * @route POST /api/notifications
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the newly created notification
 */
exports.createNotification = async (req, res) => {
  try {
    const { recipient, message, type, pumpId } = req.body;

    // Validate recipient and pump ownership
    const pump = pumpId ? await Pump.findOne({ _id: pumpId, user: req.user._id }) : null;
    if (pumpId && !pump) {
      return sendResponse(res, 404, false, 'Pump not found or not authorized');
    }

    const notification = new Notification({
      recipient: recipient || req.user._id,
      message,
      type: type || 'info',
    });
    await notification.save();
    sendResponse(res, 201, true, 'Notification created successfully', notification);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getUserNotifications
 * @description Retrieves all notifications for the authenticated user.
 * @route GET /api/notifications
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with an array of notifications
 */
exports.getUserNotifications = async (req, res) => {
  try {
    const notifications = await Notification.find({ recipient: req.user._id })
      .sort({ createdAt: -1 })
      .populate('recipient', 'name email');
    sendResponse(res, 200, true, 'Notifications fetched successfully', notifications);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function markNotificationAsRead
 * @description Marks a specific notification as read for the authenticated user.
 * @route PATCH /api/notifications/:id/read
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the updated notification
 */
exports.markNotificationAsRead = async (req, res) => {
  try {
    const notification = await Notification.findOneAndUpdate(
      { _id: req.params.id, recipient: req.user._id },
      { isRead: true },
      { new: true }
    );
    if (!notification) {
      return sendResponse(res, 404, false, 'Notification not found or not authorized');
    }
    sendResponse(res, 200, true, 'Notification marked as read', notification);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function deleteNotification
 * @description Deletes a specific notification for the authenticated user.
 * @route DELETE /api/notifications/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success message
 */
exports.deleteNotification = async (req, res) => {
  try {
    const notification = await Notification.findOneAndDelete({
      _id: req.params.id,
      recipient: req.user._id,
    });
    if (!notification) {
      return sendResponse(res, 404, false, 'Notification not found or not authorized');
    }
    sendResponse(res, 200, true, 'Notification deleted successfully');
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function markAllNotificationsAsRead
 * @description Marks all notifications for the authenticated user as read.
 * @route PATCH /api/notifications/read-all
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success message
 */
exports.markAllNotificationsAsRead = async (req, res) => {
  try {
    await Notification.updateMany(
      { recipient: req.user._id, isRead: false },
      { isRead: true }
    );
    sendResponse(res, 200, true, 'All notifications marked as read');
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

