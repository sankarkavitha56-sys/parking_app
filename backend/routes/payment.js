const express = require('express');
const router = express.Router();
const Booking = require('../models/Booking');

// Initiate payment for a booking
router.post('/initiate', async (req, res) => {
  try {
    const { bookingId, amount } = req.body;
    // TODO: integrate Razorpay here later
    res.json({ success: true, message: 'Payment initiated', bookingId, amount });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

// Confirm payment
router.post('/confirm', async (req, res) => {
  try {
    const { bookingId, paymentId, orderId } = req.body;
    if (!bookingId) {
      return res.status(400).json({ error: 'bookingId is required' });
    }
    const booking = await Booking.findByIdAndUpdate(
      bookingId,
      { paymentStatus: 'completed', paymentId, orderId },
      { new: true }
    );
    if (!booking) {
      return res.status(404).json({ error: 'Booking not found' });
    }
    res.json({ success: true, message: 'Payment confirmed', booking });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
