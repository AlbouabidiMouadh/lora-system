const express = require('express');
const router = express.Router();
const sensorController = require('../controllers/sensorController');
const { protect } = require('../middlewares/auth');

router.post('/', protect, sensorController.createSensor);
router.get('/', protect, sensorController.getSensors);
router.get('/user', protect, sensorController.getAllSensorsByUserId);
router.get('/:id', protect, sensorController.getSensorById);
router.put('/:id', protect, sensorController.updateSensor);
router.delete('/:id', protect, sensorController.deleteSensor);

module.exports = router;
