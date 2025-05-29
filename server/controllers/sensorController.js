const Sensor = require('../models/Sensor');
const { sendResponse } = require('../utils/helpers');

/**
 * @function createSensor
 * @description Creates a new sensor entry with provided data.
 * @route POST /api/sensors
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the created sensor data
 */
exports.createSensor = async (req, res) => {
  try {
    const sensor = new Sensor({ ...req.body, user: req.user._id });
    await sensor.save();
    sendResponse(res, 201, true, 'Sensor created successfully', sensor);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getSensors
 * @description Retrieves all sensors from the database.
 * @route GET /api/sensors
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response containing an array of all sensors
 */
exports.getSensors = async (req, res) => {
  try {
    const sensors = await Sensor.find();
    sendResponse(res, 200, true, 'Sensors fetched successfully', sensors);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function getSensorById
 * @description Retrieves a specific sensor by its ID.
 * @route GET /api/sensors/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the sensor data or error
 */
exports.getSensorById = async (req, res) => {
  try {
    const sensor = await Sensor.findById(req.params.id);
    if (!sensor) return sendResponse(res, 404, false, 'Sensor not found');
    sendResponse(res, 200, true, 'Sensor fetched successfully', sensor);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function updateSensor
 * @description Updates a sensor record by its ID.
 * @route PUT /api/sensors/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the updated sensor data
 */
exports.updateSensor = async (req, res) => {
  try {
    const sensor = await Sensor.findByIdAndUpdate(req.params.id, req.body, {
      new: true,
      runValidators: true
    });
    if (!sensor) return sendResponse(res, 404, false, 'Sensor not found');
    sendResponse(res, 200, true, 'Sensor updated successfully', sensor);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function deleteSensor
 * @description Deletes a sensor from the database by its ID.
 * @route DELETE /api/sensors/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response indicating successful deletion
 */
exports.deleteSensor = async (req, res) => {
  try {
    const sensor = await Sensor.findByIdAndDelete(req.params.id);
    if (!sensor) return sendResponse(res, 404, false, 'Sensor not found');
    sendResponse(res, 200, true, 'Sensor deleted successfully');
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getAllSensorsByUserId
 * @description Retrieves all sensors associated with the authenticated user.
 * @route GET /api/sensors/user
 * @access Private
 * @param {Object} req - Express request object with authenticated user
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with sensors owned by the user
 */
exports.getAllSensorsByUserId = async (req, res) => {
  try {
    const sensors = await Sensor.find({ user: req.user._id });
    sendResponse(res, 200, true, 'Sensors fetched successfully', sensors);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};
