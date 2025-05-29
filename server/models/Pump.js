const mongoose = require('mongoose');

const pumpSchema = new mongoose.Schema(
  {
    name: { type: String, required: true },
    status: {
      type: String,
      enum: ['on', 'off', 'maintenance'],
      default: 'off'
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

module.exports = mongoose.model('Pump', pumpSchema);
