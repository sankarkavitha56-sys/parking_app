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
    const { bookingId } = req.body;
    await Booking.findByIdAndUpdate(bookingId, { paymentStatus: 'paid' });
    res.json({ success: true, message: 'Payment confirmed' });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

module.exports = router;
