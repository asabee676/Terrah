const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/auth');

// @route   GET api/budgets
// @desc    Get all budgets for logged-in user
// @access  Private
router.get('/', auth, (req, res) => {
  db.all('SELECT * FROM budgets WHERE user_id = ?', [req.user.id], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    res.json(rows);
  });
});

// @route   POST api/budgets
// @desc    Create a budget limit for a category
// @access  Private
router.post('/', auth, (req, res) => {
  const { category, limit_amount, icon, color } = req.body;

  if (!category || limit_amount === undefined) {
    return res.status(400).json({ message: 'Please enter category and limit_amount' });
  }

  const userId = req.user.id;
  const limitVal = parseFloat(limit_amount);

  // Check if budget for this category already exists
  db.get('SELECT id FROM budgets WHERE user_id = ? AND category = ?', [userId, category], (err, row) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    if (row) {
      return res.status(400).json({ message: 'Budget for this category already exists. Please edit it instead.' });
    }

    // Calculate currently spent for this category from existing transactions of this user
    db.get(
      `SELECT SUM(amount) as total_spent FROM transactions 
       WHERE user_id = ? AND category = ? AND is_income = 0 AND status = 'Success'`,
      [userId, category],
      (err, txRow) => {
        const spentVal = txRow && txRow.total_spent ? parseFloat(txRow.total_spent) : 0.0;

        // Insert new budget
        db.run(
          `INSERT INTO budgets (user_id, category, spent, limit_amount, icon, color)
           VALUES (?, ?, ?, ?, ?, ?)`,
          [userId, category, spentVal, limitVal, icon || 'folder', color || 'blue'],
          function (err) {
            if (err) {
              return res.status(500).json({ message: 'Error creating budget', error: err.message });
            }
            res.status(201).json({
              id: this.lastID,
              user_id: userId,
              category,
              spent: spentVal,
              limit_amount: limitVal,
              icon: icon || 'folder',
              color: color || 'blue'
            });
          }
        );
      }
    );
  });
});

// @route   PUT api/budgets/:id
// @desc    Update a budget limit or detail
// @access  Private
router.put('/:id', auth, (req, res) => {
  const { limit_amount, icon, color } = req.body;

  db.get('SELECT * FROM budgets WHERE id = ? AND user_id = ?', [req.params.id, req.user.id], (err, budget) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    if (!budget) {
      return res.status(404).json({ message: 'Budget not found' });
    }

    const newLimit = limit_amount !== undefined ? parseFloat(limit_amount) : budget.limit_amount;
    const newIcon = icon !== undefined ? icon : budget.icon;
    const newColor = color !== undefined ? color : budget.color;

    db.run(
      `UPDATE budgets SET limit_amount = ?, icon = ?, color = ? WHERE id = ? AND user_id = ?`,
      [newLimit, newIcon, newColor, req.params.id, req.user.id],
      function (err) {
        if (err) {
          return res.status(500).json({ message: 'Error updating budget', error: err.message });
        }
        res.json({
          id: parseInt(req.params.id),
          user_id: req.user.id,
          category: budget.category,
          spent: budget.spent,
          limit_amount: newLimit,
          icon: newIcon,
          color: newColor
        });
      }
    );
  });
});

// @route   DELETE api/budgets/:id
// @desc    Delete a budget
// @access  Private
router.delete('/:id', auth, (req, res) => {
  db.run('DELETE FROM budgets WHERE id = ? AND user_id = ?', [req.params.id, req.user.id], function (err) {
    if (err) {
      return res.status(500).json({ message: 'Error deleting budget', error: err.message });
    }
    if (this.changes === 0) {
      return res.status(404).json({ message: 'Budget not found' });
    }
    res.json({ message: 'Budget deleted successfully' });
  });
});

module.exports = router;
