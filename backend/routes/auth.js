const express = require('express');
const router = express.Router();
const bcrypt = require('bcryptjs');
const jwt = require('jsonwebtoken');
const db = require('../db');
const auth = require('../middleware/auth');

const JWT_SECRET = process.env.JWT_SECRET || 'super_secret_budgeterra_key_12345';

// Helper to generate a dummy account number
function generateAccountNumber() {
  const segment1 = Math.floor(100 + Math.random() * 900);
  const segment2 = Math.floor(100 + Math.random() * 900);
  const segment3 = Math.floor(10 + Math.random() * 90);
  return `BE-${segment1}-${segment2}-${segment3}`;
}

// @route   POST api/auth/register
// @desc    Register a user
// @access  Public
router.post('/register', async (req, res) => {
  const { name, email, password, phone } = req.body;

  if (!name || !email || !password) {
    return res.status(400).json({ message: 'Please enter name, email, and password' });
  }

  try {
    // Check if user already exists
    db.get('SELECT id FROM users WHERE email = ?', [email], async (err, user) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (user) {
        return res.status(400).json({ message: 'User already exists' });
      }

      // Hash password
      const salt = await bcrypt.genSalt(10);
      const password_hash = await bcrypt.hash(password, salt);
      const account_number = generateAccountNumber();
      const balance = 0.0;

      // Insert new user
      db.run(
        `INSERT INTO users (name, email, password_hash, phone, account_number, balance) VALUES (?, ?, ?, ?, ?, ?)`,
        [name, email, password_hash, phone || '', account_number, balance],
        function (err) {
          if (err) {
            return res.status(500).json({ message: 'Error registering user', error: err.message });
          }

          const userId = this.lastID;

          // Generate Token
          const payload = { id: userId };
          jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' }, (err, token) => {
            if (err) throw err;
            res.json({
              token,
              user: {
                id: userId,
                name,
                email,
                phone,
                account_number,
                balance
              }
            });
          });
        }
      );
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// @route   POST api/auth/login
// @desc    Authenticate user & get token
// @access  Public
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ message: 'Please enter email and password' });
  }

  try {
    db.get('SELECT * FROM users WHERE email = ?', [email], async (err, user) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (!user) {
        return res.status(400).json({ message: 'Invalid credentials' });
      }

      // Check password
      const isMatch = await bcrypt.compare(password, user.password_hash);
      if (!isMatch) {
        return res.status(400).json({ message: 'Invalid credentials' });
      }

      // Generate Token
      const payload = { id: user.id };
      jwt.sign(payload, JWT_SECRET, { expiresIn: '7d' }, (err, token) => {
        if (err) throw err;
        res.json({
          token,
          user: {
            id: user.id,
            name: user.name,
            email: user.email,
            phone: user.phone,
            account_number: user.account_number,
            balance: user.balance
          }
        });
      });
    });
  } catch (err) {
    res.status(500).json({ message: 'Server error', error: err.message });
  }
});

// @route   GET api/auth/me
// @desc    Get user data
// @access  Private
router.get('/me', auth, (req, res) => {
  db.get('SELECT id, name, email, phone, account_number, balance, created_at FROM users WHERE id = ?', [req.user.id], (err, user) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    if (!user) {
      return res.status(404).json({ message: 'User not found' });
    }
    res.json(user);
  });
});

module.exports = router;
