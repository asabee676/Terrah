const express = require('express');
const router = express.Router();
const db = require('../db');

// Enable foreign keys explicitly for SQLite connections
db.run('PRAGMA foreign_keys = ON');

// @route   GET api/admin/stats
// @desc    Get system-wide analytics and statistics
// @access  Public (for local dev/admin dashboard purposes)
router.get('/stats', (req, res) => {
  const stats = {};

  db.serialize(() => {
    // 1. Total Users
    db.get('SELECT COUNT(*) as count, AVG(balance) as avg_balance, SUM(balance) as total_balance FROM users', [], (err, row) => {
      if (err) return res.status(500).json({ message: 'Error fetching users stats', error: err.message });
      stats.total_users = row.count;
      stats.avg_user_balance = parseFloat((row.avg_balance || 0).toFixed(2));
      stats.total_user_balance = parseFloat((row.total_balance || 0).toFixed(2));

      // 2. Total Transactions Stats
      db.get(
        `SELECT COUNT(*) as count, 
                SUM(amount) as total_volume,
                SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) as total_income,
                SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) as total_expense
         FROM transactions WHERE status = 'Success'`,
        [],
        (err, txRow) => {
          if (err) return res.status(500).json({ message: 'Error fetching transaction stats', error: err.message });
          stats.total_transactions = txRow.count;
          stats.total_volume = parseFloat((txRow.total_volume || 0).toFixed(2));
          stats.total_income = parseFloat((txRow.total_income || 0).toFixed(2));
          stats.total_expense = parseFloat((txRow.total_expense || 0).toFixed(2));

          // 3. Remittances Count
          db.get('SELECT COUNT(*) as count, SUM(amount) as total_remitted FROM remittances WHERE status = "Successful"', [], (err, remRow) => {
            if (err) return res.status(500).json({ message: 'Error fetching remittance stats', error: err.message });
            stats.total_remittances = remRow.count;
            stats.total_remitted_amount = parseFloat((remRow.total_remitted || 0).toFixed(2));

            // 4. Get 10 Recent Transactions Across the Platform (joined with user names)
            db.all(
              `SELECT t.*, u.name as user_name, u.email as user_email
               FROM transactions t
               JOIN users u ON t.user_id = u.id
               ORDER BY t.date DESC, t.id DESC
               LIMIT 10`,
              [],
              (err, txList) => {
                if (err) return res.status(500).json({ message: 'Error fetching recent transactions', error: err.message });
                stats.recent_transactions = txList;

                res.json(stats);
              }
            );
          });
        }
      );
    });
  });
});

// @route   GET api/admin/users
// @desc    Get all users with their transaction counts
// @access  Public
router.get('/users', (req, res) => {
  db.all(
    `SELECT u.id, u.name, u.email, u.phone, u.account_number, u.balance, u.created_at,
            COUNT(t.id) as transactions_count
     FROM users u
     LEFT JOIN transactions t ON u.id = t.user_id
     GROUP BY u.id
     ORDER BY u.created_at DESC`,
    [],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      res.json(rows);
    }
  );
});

// @route   DELETE api/admin/users/:id
// @desc    Delete user and cascade delete their transactions/budgets/remittances
// @access  Public
router.delete('/users/:id', (req, res) => {
  const userId = req.params.id;

  db.serialize(() => {
    // Explicitly clean up all records (in case SQLite PRAGMA cascade wasn't activated)
    db.run('DELETE FROM transactions WHERE user_id = ?', [userId]);
    db.run('DELETE FROM budgets WHERE user_id = ?', [userId]);
    db.run('DELETE FROM remittances WHERE user_id = ?', [userId]);
    db.run('DELETE FROM users WHERE id = ?', [userId], function (err) {
      if (err) {
        return res.status(500).json({ message: 'Error deleting user', error: err.message });
      }
      if (this.changes === 0) {
        return res.status(404).json({ message: 'User not found' });
      }
      res.json({ message: 'User and all related records deleted successfully' });
    });
  });
});

// @route   GET api/admin/transactions
// @desc    Get all transactions across the system (with username)
// @access  Public
router.get('/transactions', (req, res) => {
  db.all(
    `SELECT t.*, u.name as user_name, u.email as user_email
     FROM transactions t
     JOIN users u ON t.user_id = u.id
     ORDER BY t.date DESC, t.id DESC`,
    [],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      res.json(rows);
    }
  );
});

// @route   GET api/admin/remittances
// @desc    Get all remittances across the system (with username)
// @access  Public
router.get('/remittances', (req, res) => {
  db.all(
    `SELECT r.*, u.name as user_name, u.email as user_email
     FROM remittances r
     JOIN users u ON r.user_id = u.id
     ORDER BY r.date DESC, r.id DESC`,
    [],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      res.json(rows);
    }
  );
});

// @route   GET api/admin/users/:id/budgets
// @desc    Get budgets for a specific user
// @access  Public
router.get('/users/:id/budgets', (req, res) => {
  db.all('SELECT * FROM budgets WHERE user_id = ?', [req.params.id], (err, rows) => {
    if (err) {
      return res.status(500).json({ message: 'Database error', error: err.message });
    }
    res.json(rows);
  });
});

// @route   GET api/admin/users/:id/analytics/breakdown
// @desc    Get category-wise expense breakdown for a user
// @access  Public
router.get('/users/:id/analytics/breakdown', (req, res) => {
  const userId = req.params.id;
  db.all(
    `SELECT category, SUM(amount) as total, icon, color 
     FROM transactions 
     WHERE user_id = ? AND is_income = 0 AND status = 'Success'
     GROUP BY category 
     ORDER BY total DESC`,
    [userId],
    (err, rows) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      const grandTotal = rows.reduce((sum, row) => sum + row.total, 0);
      const result = rows.map(row => ({
        category: row.category,
        total: row.total,
        percentage: grandTotal > 0 ? parseFloat(((row.total / grandTotal) * 100).toFixed(1)) : 0,
        icon: row.icon,
        color: row.color
      }));
      res.json({
        total_expense: grandTotal,
        categories: result
      });
    }
  );
});

// @route   GET api/admin/users/:id/analytics/chart
// @desc    Get analytics chart data for a specific user
// @access  Public
router.get('/users/:id/analytics/chart', (req, res) => {
  const userId = req.params.id;
  const period = req.query.period || 'week';
  const now = new Date();

  if (period === 'week') {
    const days = [];
    for (let i = 6; i >= 0; i--) {
      const d = new Date(now);
      d.setDate(d.getDate() - i);
      days.push(d.toISOString().split('T')[0]);
    }
    const placeholders = days.map(() => '?').join(',');
    db.all(
      `SELECT date, 
              SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) as income,
              SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) as expense
       FROM transactions
       WHERE user_id = ? AND date IN (${placeholders}) AND status = 'Success'
       GROUP BY date`,
      [userId, ...days],
      (err, rows) => {
        if (err) return res.status(500).json({ message: 'Database error', error: err.message });
        const rowMap = {};
        rows.forEach(r => { rowMap[r.date] = r; });
        const chartData = days.map(d => {
          const dayName = new Date(d).toLocaleDateString('en-US', { weekday: 'short' });
          return {
            label: dayName,
            date: d,
            income: rowMap[d] ? parseFloat(rowMap[d].income) : 0.0,
            expense: rowMap[d] ? parseFloat(rowMap[d].expense) : 0.0
          };
        });
        res.json(chartData);
      }
    );
  } else if (period === 'month') {
    const chartData = [];
    const runQueries = (weekIndex) => {
      if (weekIndex >= 4) {
        return res.json(chartData.reverse());
      }
      const startOffset = weekIndex * 7;
      const endOffset = (weekIndex + 1) * 7 - 1;
      const dStart = new Date(now);
      dStart.setDate(dStart.getDate() - endOffset);
      const dEnd = new Date(now);
      dEnd.setDate(dEnd.getDate() - startOffset);
      const startStr = dStart.toISOString().split('T')[0];
      const endStr = dEnd.toISOString().split('T')[0];

      db.get(
        `SELECT SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) as income,
                SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) as expense
         FROM transactions
         WHERE user_id = ? AND date BETWEEN ? AND ? AND status = 'Success'`,
        [userId, startStr, endStr],
        (err, row) => {
          if (err) return res.status(500).json({ message: 'Database error', error: err.message });
          chartData.push({
            label: `Week ${4 - weekIndex}`,
            range: `${dStart.toLocaleDateString('en-US', {month: 'short', day: 'numeric'})} - ${dEnd.toLocaleDateString('en-US', {month: 'short', day: 'numeric'})}`,
            income: row && row.income ? parseFloat(row.income) : 0.0,
            expense: row && row.expense ? parseFloat(row.expense) : 0.0
          });
          runQueries(weekIndex + 1);
        }
      );
    };
    runQueries(0);
  } else if (period === 'year') {
    const months = [];
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      months.push({
        year: d.getFullYear(),
        month: d.getMonth() + 1,
        label: d.toLocaleDateString('en-US', { month: 'short' })
      });
    }
    const chartData = [];
    const runQueries = (monthIdx) => {
      if (monthIdx >= 12) {
        return res.json(chartData);
      }
      const m = months[monthIdx];
      const yearStr = m.year.toString();
      const monthStr = m.month < 10 ? `0${m.month}` : m.month.toString();
      const prefix = `${yearStr}-${monthStr}%`;
      db.get(
        `SELECT SUM(CASE WHEN is_income = 1 THEN amount ELSE 0 END) as income,
                SUM(CASE WHEN is_income = 0 THEN amount ELSE 0 END) as expense
         FROM transactions
         WHERE user_id = ? AND date LIKE ? AND status = 'Success'`,
        [userId, prefix],
        (err, row) => {
          if (err) return res.status(500).json({ message: 'Database error', error: err.message });
          chartData.push({
            label: `${m.label} ${yearStr.slice(-2)}`,
            income: row && row.income ? parseFloat(row.income) : 0.0,
            expense: row && row.expense ? parseFloat(row.expense) : 0.0
          });
          runQueries(monthIdx + 1);
        }
      );
    };
    runQueries(0);
  } else {
    res.status(400).json({ message: 'Invalid period parameter. Use week, month, or year.' });
  }
});

// @route   PUT api/admin/remittances/:id/status
// @desc    Update remittance status administratively (updates balance & transaction)
// @access  Public
router.put('/remittances/:id/status', (req, res) => {
  const { status } = req.body;

  if (!status) {
    return res.status(400).json({ message: 'Please provide a status' });
  }

  db.serialize(() => {
    db.get('SELECT * FROM remittances WHERE id = ?', [req.params.id], (err, rem) => {
      if (err) {
        return res.status(500).json({ message: 'Database error', error: err.message });
      }
      if (!rem) {
        return res.status(404).json({ message: 'Remittance not found' });
      }

      const userId = rem.user_id;
      const oldStatus = rem.status;
      const newStatus = status;

      if (oldStatus === newStatus) {
        return res.json(rem);
      }

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

        // Update status of synced transaction
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
