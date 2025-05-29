const jwt = require('jsonwebtoken');
const User = require('../models/User');
const { sendResponse } = require('../utils/helpers');

exports.protect = async (req, res, next) => {
  let token = req.headers.authorization?.split(' ')[1];

  if (!token) return sendResponse(res, 401, false, 'No token, authorization denied');

  try {
    const decoded = jwt.verify(token, process.env.JWT_SECRET);
    req.user = await User.findById(decoded.id).select('-password');
    next();
  } catch (err) {
    sendResponse(res, 401, false, 'Token invalid or expired');
  }
};
