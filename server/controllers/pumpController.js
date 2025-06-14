const Pump = require('../models/Pump');
const Sensor = require('../models/Sensor');
const { sendResponse } = require('../utils/helpers');

/**
 * @function createPump
 * @description Creates a new pump record in the database.
 * @route POST /api/pumps
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the newly created pump
 */
exports.createPump = async (req, res) => {
  try {
    const { name, longitude, latitude, description } = req.body;
    const pump = new Pump({ name, longitude, latitude, description, user: req.user._id });
    await pump.save();
    sendResponse(res, 201, true, 'Pump created successfully', pump);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getPumps
 * @description Retrieves all pump records with their related sensors.
 * @route GET /api/pumps
 * @access Private/Admin
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response containing an array of pumps with their sensors
 */
exports.getPumps = async (req, res) => {
  try {
    const pumps = await Pump.find();
    const pumpsWithSensors = await Promise.all(
      pumps.map(async (pump) => {
        const sensors = await Sensor.find({ pump: pump._id });
        return { ...pump.toObject(), sensors };
      })
    );
    sendResponse(res, 200, true, 'Pumps fetched successfully', pumpsWithSensors);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function getPumpById
 * @description Retrieves a single pump by its ID with its related sensors.
 * @route GET /api/pumps/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with pump data and its sensors or error
 */
exports.getPumpById = async (req, res) => {
  try {
    const pump = await Pump.findById(req.params.id);
    if (!pump) return sendResponse(res, 404, false, 'Pump not found');
    const sensors = await Sensor.find({ pump: pump._id });
    sendResponse(res, 200, true, 'Pump fetched successfully', { ...pump.toObject(), sensors });
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function updatePump
 * @description Updates a pump's data by ID.
 * @route PUT /api/pumps/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the updated pump data
 */
exports.updatePump = async (req, res) => {
  try {
    const { name, longitude, latitude, description, status } = req.body;
    const updateData = { name, longitude, latitude, description, status };
    const pump = await Pump.findByIdAndUpdate(req.params.id, updateData, {
      new: true,
      runValidators: true
    });
    if (!pump) return sendResponse(res, 404, false, 'Pump not found');
    sendResponse(res, 200, true, 'Pump updated successfully', pump);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function deletePump
 * @description Deletes a pump record by ID.
 * @route DELETE /api/pumps/:id
 * @access Private
 * @param {Object} req - Express request object
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with success message
 */
exports.deletePump = async (req, res) => {
  try {
    const pump = await Pump.findByIdAndDelete(req.params.id);
    if (!pump) return sendResponse(res, 404, false, 'Pump not found');
    sendResponse(res, 200, true, 'Pump deleted successfully');
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};

/**
 * @function getPumpsByUserId
 * @description Retrieves all pumps associated with the currently authenticated user with their related sensors.
 * @route GET /api/pumps/user
 * @access Private
 * @param {Object} req - Express request object (with authenticated user)
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with an array of pumps with their sensors
 */
exports.getPumpsByUserId = async (req, res) => {
  try {
    const pumps = await Pump.find({ user: req.user._id });
    const pumpsWithSensors = await Promise.all(
      pumps.map(async (pump) => {
        const sensors = await Sensor.find({ pump: pump._id });
        return { ...pump.toObject(), sensors };
      })
    );
    sendResponse(res, 200, true, 'User pumps fetched successfully', pumpsWithSensors);
  } catch (err) {
    sendResponse(res, 500, false, err.message);
  }
};

/**
 * @function updatePumpStatus
 * @description Updates only the `status` field of a pump belonging to the authenticated user.
 * @route PATCH /api/pumps/:id/status
 * @access Private
 * @param {Object} req - Express request object (with `status` in body and authenticated user)
 * @param {Object} res - Express response object
 * @returns {Object} JSON response with the updated pump
 */
exports.updatePumpStatus = async (req, res) => {
  try {
    const { status } = req.body;
    if (!['on', 'off', 'maintenance'].includes(status)) {
      return sendResponse(res, 400, false, 'Invalid status value');
    }

    const pump = await Pump.findOneAndUpdate(
      { _id: req.params.id, user: req.user._id },
      { status },
      { new: true }
    );

    if (!pump) return sendResponse(res, 404, false, 'Pump not found or not authorized');

    sendResponse(res, 200, true, 'Pump status updated successfully', pump);
  } catch (err) {
    sendResponse(res, 400, false, err.message);
  }
};