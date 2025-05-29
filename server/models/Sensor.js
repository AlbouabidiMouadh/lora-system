const mongoose = require('mongoose');

const sensorSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    temperature: { type: Number, required: true },
    humidity: { type: Number, required: true },
    waterCapacity: { type: Number, required: true },
    status: {
      type: String,
      enum: ['active', 'inactive', 'error'],
      default: 'active'
    },
    longitude: { type: Number, required: true },
    latitude: { type: Number, required: true },
    description: { type: String, default: '' },
    user: {
      type: mongoose.Schema.Types.ObjectId,
      ref: 'User',
      required: true
    }
  },
  { timestamps: true }
);

module.exports = mongoose.model('Sensor', sensorSchema);
