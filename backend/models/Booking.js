// backend/models/Booking.js
const mongoose = require('mongoose');

const BookingSchema = new mongoose.Schema({
  spotId: { type: mongoose.Schema.Types.ObjectId, ref: 'ParkingSpot' },
  userId: { type: mongoose.Schema.Types.ObjectId, ref: 'User' },
  paymentStatus: {
    type: String,
    enum: ['pending', 'completed', 'failed'],
    default: 'pending',
  },
  paymentId: { type: String, default: null },
  orderId: { type: String, default: null },
  paymentAmount: { type: Number, default: 0 },
  qrCode: { type: String, default: null }, // QR code image as base64
}, { timestamps: true });

module.exports = mongoose.model('Booking', BookingSchema);
