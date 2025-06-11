const express = require('express');
const router = express.Router();
const notificationController = require('../controllers/notificationController');
const { protect } = require('../middlewares/auth');

router.post('/', protect, notificationController.createNotification);
router.get('/', protect, notificationController.getUserNotifications);
router.patch('/:id/read', protect, notificationController.markNotificationAsRead);
router.patch('/read-all', protect, notificationController.markAllNotificationsAsRead);
router.delete('/:id', protect, notificationController.deleteNotification);

module.exports = router;