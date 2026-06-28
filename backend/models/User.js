// backend/models/User.js
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');

const userSchema = new mongoose.Schema({
  username: { type: String, required: true, unique: true },
  password: { type: String, required: true },
  role: { type: String, enum: ['admin', 'user'], default: 'user' },
}, { timestamps: true });

userSchema.pre('save', async function(next) {
  if (!this.isModified('password')) return next();
  this.password = await bcrypt.hash(this.password, 10);
  next();
});

userSchema.methods.comparePassword = async function(password) {
  return await bcrypt.compare(password, this.password);
};

// Never expose the password hash (or internal version key) in API responses.
function sanitizeUser(doc, ret) {
  delete ret.password;
  delete ret.__v;
  return ret;
}
userSchema.set('toJSON', { transform: sanitizeUser });
userSchema.set('toObject', { transform: sanitizeUser });

module.exports = mongoose.model('User', userSchema);