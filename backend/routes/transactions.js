const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/auth');

// @route   GET api/transactions
// @desc    Get all transactions for user
// @access  Private
router.get('/', auth, (req, res) => {
  db.all('SELECT * FROM transactions WHERE user_id = ? ORDER BY date DESC, id DESC', [req.user.id], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    res.json(rows);
  });
});

// @route   GET api/transactions/:id
// @desc    Get single transaction
// @access  Private
router.get('/:id', auth, (req, res) => {
  db.get('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id], (err, row) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    if (!row) {
      return res.status(404).json({ message: 'Transaction not found' });
    }
    res.json(row);
  });
});

// @route   POST api/transactions
// @desc    Create a transaction
// @access  Private
router.post('/', auth, (req, res) => {
  const { title, subtitle, amount, is_income, category, account, status, date, icon, color } = req.body;

  if (!title || amount === undefined || is_income === undefined || !category || !date) {
    return res.status(400).json({ message: 'Please enter title, amount, is_income, category, and date' });
  }

  const userId = req.user.id;
  const numericAmount = parseFloat(amount);
  const isIncomeVal = is_income ? 1 : 0;

  // We perform these updates in a serial way to avoid race conditions
  db.serialize(() => {
    // 1. Get user balance
    db.get('SELECT balance FROM users WHERE id = ?', [userId], (err, user) => {
      if (err) {
        return res.status(500).json({ message: 'Error checking user balance', error: err.message });
      }
      if (!user) {
        return res.status(404).json({ message: 'User not found' });
      }

      // Calculate new balance
      const balanceChange = isIncomeVal === 1 ? numericAmount : -numericAmount;
      const newBalance = user.balance + balanceChange;

      // 2. Insert transaction
      db.run(
        `INSERT INTO transactions (user_id, title, subtitle, amount, is_income, category, account, status, date, icon, color)
         VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)`,
        [userId, title, subtitle || '', numericAmount, isIncomeVal, category, account || 'Wallet', status || 'Success', date, icon || 'payment', color || 'blue'],
        function (err) {
          if (err) {
            return res.status(500).json({ message: 'Error inserting transaction', error: err.message });
          }

          const newTransactionId = this.lastID;

          // 3. Update User Balance
          db.run('UPDATE users SET balance = ? WHERE id = ?', [newBalance, userId], (err) => {
            if (err) {
              console.error('Failed to update user balance:', err.message);
            }
          });

          // 4. Update Budget spent (if expense and budget category exists)
          if (isIncomeVal === 0) {
            db.run(
              'UPDATE budgets SET spent = spent + ? WHERE user_id = ? AND category = ?',
              [numericAmount, userId, category],
              (err) => {
                if (err) {
                  console.error('Failed to update budget spent:', err.message);
                }
              }
            );
          }

          // Return created transaction details
          res.status(201).json({
            id: newTransactionId,
            user_id: userId,
            title,
            subtitle,
            amount: numericAmount,
            is_income: isIncomeVal,
            category,
            account,
            status: status || 'Success',
            date,
            icon,
            color,
            updated_user_balance: newBalance
          });
        }
      );
    });
  });
});

// @route   PUT api/transactions/:id
// @desc    Update a transaction
// @access  Private
router.put('/:id', auth, (req, res) => {
  const { title, subtitle, amount, is_income, category, account, status, date, icon, color } = req.body;

  db.serialize(() => {
    // 1. Get original transaction to revert its changes
    db.get('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id], (err, oldTx) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (!oldTx) {
        return res.status(404).json({ message: 'Transaction not found' });
      }

      const userId = req.user.id;
      
      // Values to update
      const newTitle = title !== undefined ? title : oldTx.title;
      const newSubtitle = subtitle !== undefined ? subtitle : oldTx.subtitle;
      const newAmount = amount !== undefined ? parseFloat(amount) : oldTx.amount;
      const newIsIncome = is_income !== undefined ? (is_income ? 1 : 0) : oldTx.is_income;
      const newCategory = category !== undefined ? category : oldTx.category;
      const newAccount = account !== undefined ? account : oldTx.account;
      const newStatus = status !== undefined ? status : oldTx.status;
      const newDate = date !== undefined ? date : oldTx.date;
      const newIcon = icon !== undefined ? icon : oldTx.icon;
      const newColor = color !== undefined ? color : oldTx.color;

      // Revert old transaction in database (user balance and budget)
      db.get('SELECT balance FROM users WHERE id = ?', [userId], (err, user) => {
        if (err || !user) {
          return res.status(500).json({ message: 'Error checking user' });
        }

        // Revert old tx: subtract income, add expense back to user balance
        const balanceAfterRevert = user.balance - (oldTx.is_income === 1 ? oldTx.amount : -oldTx.amount);
        
        // Revert old budget spent
        if (oldTx.is_income === 0) {
          db.run(
            'UPDATE budgets SET spent = spent - ? WHERE user_id = ? AND category = ?',
            [oldTx.amount, userId, oldTx.category]
          );
        }

        // Calculate new balance
        const finalBalance = balanceAfterRevert + (newIsIncome === 1 ? newAmount : -newAmount);

        // Apply new budget spent
        if (newIsIncome === 0) {
          db.run(
            'UPDATE budgets SET spent = spent + ? WHERE user_id = ? AND category = ?',
            [newAmount, userId, newCategory]
          );
        }

        // 2. Update user balance
        db.run('UPDATE users SET balance = ? WHERE id = ?', [finalBalance, userId]);

        // 3. Update transaction
        db.run(
          `UPDATE transactions SET 
            title = ?, subtitle = ?, amount = ?, is_income = ?, category = ?, 
            account = ?, status = ?, date = ?, icon = ?, color = ?
           WHERE id = ? AND user_id = ?`,
          [newTitle, newSubtitle, newAmount, newIsIncome, newCategory, newAccount, newStatus, newDate, newIcon, newColor, req.params.id, userId],
          function (err) {
            if (err) {
              return res.status(500).json({ message: 'Error updating transaction', error: err.message });
            }

            res.json({
              id: parseInt(req.params.id),
              user_id: userId,
              title: newTitle,
              subtitle: newSubtitle,
              amount: newAmount,
              is_income: newIsIncome,
              category: newCategory,
              account: newAccount,
              status: newStatus,
              date: newDate,
              icon: newIcon,
              color: newColor,
              updated_user_balance: finalBalance
            });
          }
        );
      });
    });
  });
});

// @route   DELETE api/transactions/:id
// @desc    Delete a transaction
// @access  Private
router.delete('/:id', auth, (req, res) => {
  db.serialize(() => {
    // 1. Get original transaction to revert its changes
    db.get('SELECT * FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, req.user.id], (err, tx) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (!tx) {
        return res.status(404).json({ message: 'Transaction not found' });
      }

      const userId = req.user.id;

      // 2. Revert user balance
      db.get('SELECT balance FROM users WHERE id = ?', [userId], (err, user) => {
        if (err || !user) {
          return res.status(500).json({ message: 'Error retrieving user' });
        }

        const restoredBalance = user.balance - (tx.is_income === 1 ? tx.amount : -tx.amount);
        
        db.run('UPDATE users SET balance = ? WHERE id = ?', [restoredBalance, userId]);

        // 3. Revert budget spent
        if (tx.is_income === 0) {
          db.run(
            'UPDATE budgets SET spent = spent - ? WHERE user_id = ? AND category = ?',
            [tx.amount, userId, tx.category]
          );
        }

        // 4. Delete transaction
        db.run('DELETE FROM transactions WHERE id = ? AND user_id = ?', [req.params.id, userId], (err) => {
          if (err) {
            return res.status(500).json({ message: 'Error deleting transaction', error: err.message });
          }
          res.json({ message: 'Transaction deleted successfully', updated_user_balance: restoredBalance });
        });
      });
    });
  });
});

module.exports = router;
