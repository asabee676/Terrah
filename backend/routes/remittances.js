const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/auth');

// @route   GET api/remittances
// @desc    Get all remittances for user
// @access  Private
router.get('/', auth, (req, res) => {
  db.all('SELECT * FROM remittances WHERE user_id = ? ORDER BY date DESC, id DESC', [req.user.id], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    res.json(rows);
  });
});

// @route   POST api/remittances
// @desc    Create a remittance
// @access  Private
router.post('/', auth, (req, res) => {
  const { recipient, amount, status, date } = req.body;

  if (!recipient || amount === undefined || !date) {
    return res.status(400).json({ message: 'Please enter recipient, amount, and date' });
  }

  const userId = req.user.id;
  const numAmount = parseFloat(amount);
  const remStatus = status || 'Pending';

  db.serialize(() => {
    // 1. Get user balance
    db.get('SELECT balance FROM users WHERE id = ?', [userId], (err, user) => {
      if (err || !user) {
        return res.status(500).json({ message: 'Error checking user balance' });
      }

      // Deduct if status is Pending or Successful. Reverted if Failed.
      let newBalance = user.balance;
      if (remStatus !== 'Failed') {
        newBalance -= numAmount;
      }

      // 2. Insert Remittance
      db.run(
        `INSERT INTO remittances (user_id, recipient, amount, status, date) VALUES (?, ?, ?, ?, ?)`,
        [userId, recipient, numAmount, remStatus, date],
        function (err) {
          if (err) {
            return res.status(500).json({ message: 'Error creating remittance', error: err.message });
          }

          const remId = this.lastID;

          // 3. Create a synced transaction
          db.run(
            `INSERT INTO transactions (user_id, title, subtitle, amount, is_income, category, account, status, date, icon, color)
             VALUES (?, ?, ?, ?, 0, 'Transfer', 'Main Account', ?, ?, 'send', 'purple')`,
            [userId, `Remittance to ${recipient}`, `Transfer ref #${remId}`, numAmount, remStatus, date],
            (err) => {
              if (err) {
                console.error('Failed to create synced transaction for remittance:', err.message);
              }
            }
          );

          // 4. Update user balance
          db.run('UPDATE users SET balance = ? WHERE id = ?', [newBalance, userId], (err) => {
            if (err) {
              console.error('Failed to update user balance:', err.message);
            }
          });

          res.status(201).json({
            id: remId,
            user_id: userId,
            recipient,
            amount: numAmount,
            status: remStatus,
            date,
            updated_user_balance: newBalance
          });
        }
      );
    });
  });
});

// @route   PUT api/remittances/:id/status
// @desc    Update remittance status (called by user or admin dashboard)
// @access  Private (or admin)
router.put('/:id/status', auth, (req, res) => {
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ message: 'Please provide a status' });
  }

  db.serialize(() => {
    // 1. Get original remittance
    db.get('SELECT * FROM remittances WHERE id = ?', [req.params.id], (err, rem) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (!rem) {
        return res.status(404).json({ message: 'Remittance not found' });
      }

      const userId = rem.user_id; // Use owner's ID
      const oldStatus = rem.status;
      const newStatus = status;

      if (oldStatus === newStatus) {
        return res.json(rem);
      }

      // Check user balance to adjust
      db.get('SELECT balance FROM users WHERE id = ?', [userId], (err, user) => {
        if (err || !user) {
          return res.status(500).json({ message: 'Error checking user balance' });
        }

        let finalBalance = user.balance;

        // If it WAS Failed and now is Pending/Successful -> Deduct
        if (oldStatus === 'Failed' && newStatus !== 'Failed') {
          finalBalance -= rem.amount;
        }
        // If it WAS NOT Failed and now IS Failed -> Refund
        else if (oldStatus !== 'Failed' && newStatus === 'Failed') {
          finalBalance += rem.amount;
        }

        // Update status of remittance
        db.run('UPDATE remittances SET status = ? WHERE id = ?', [newStatus, rem.id]);

        // Update status of synced transaction (identified by subtitle text)
        db.run(
          `UPDATE transactions SET status = ? 
           WHERE user_id = ? AND category = 'Transfer' AND subtitle = ?`,
          [newStatus, userId, `Transfer ref #${rem.id}`]
        );

        // Update user balance
        db.run('UPDATE users SET balance = ? WHERE id = ?', [finalBalance, userId]);

        res.json({
          id: rem.id,
          user_id: userId,
          recipient: rem.recipient,
          amount: rem.amount,
          status: newStatus,
          date: rem.date,
          updated_user_balance: finalBalance
        });
      });
    });
  });
});

module.exports = router;
