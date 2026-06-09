const express = require('express');
const router = express.Router();
const db = require('../db');
const auth = require('../middleware/auth');

// @route   GET api/analytics/summary
// @desc    Get financial summary (total income, expense, balance)
// @access  Private
router.get('/summary', auth, (req, res) => {
  const userId = req.user.id;

  const queries = {
    income: `SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND is_income = 1 AND status = 'Success'`,
    expense: `SELECT SUM(amount) as total FROM transactions WHERE user_id = ? AND is_income = 0 AND status = 'Success'`,
    user: `SELECT balance FROM users WHERE id = ?`
  };

  db.get(queries.income, [userId], (err, incRow) => {
    if (err) return res.status(500).json({ message: 'Database error', error: err.message });
    
    db.get(queries.expense, [userId], (err, expRow) => {
      if (err) return res.status(500).json({ message: 'Database error', error: err.message });

      db.get(queries.user, [userId], (err, userRow) => {
        if (err) return res.status(500).json({ message: 'Database error', error: err.message });
        if (!userRow) return res.status(404).json({ message: 'User not found' });

        const totalIncome = incRow && incRow.total ? parseFloat(incRow.total) : 0.0;
        const totalExpense = expRow && expRow.total ? parseFloat(expRow.total) : 0.0;

        res.json({
          balance: userRow.balance,
          total_income: totalIncome,
          total_expense: totalExpense,
          net_savings: totalIncome - totalExpense
        });
      });
    });
  });
});

// @route   GET api/analytics/breakdown
// @desc    Get category breakdown for expenses
// @access  Private
router.get('/breakdown', auth, (req, res) => {
  const userId = req.user.id;

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

      // Calculate total expense to add percentages
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

// @route   GET api/analytics/chart
// @desc    Get chart data for week, month, or year
// @access  Private
router.get('/chart', auth, (req, res) => {
  const userId = req.user.id;
  const period = req.query.period || 'week'; // week, month, year

  const now = new Date();
  
  if (period === 'week') {
    // Last 7 days
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
    // Last 30 days grouped by weekly ranges (or just day by day for simplicity, or 4-5 blocks)
    // Let's do 4 weeks grouping
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
    // Last 12 months
    const months = [];
    for (let i = 11; i >= 0; i--) {
      const d = new Date(now.getFullYear(), now.getMonth() - i, 1);
      months.push({
        year: d.getFullYear(),
        month: d.getMonth() + 1, // 1-indexed
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
      const prefix = `${yearStr}-${monthStr}%`; // Like '2026-06%'

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

module.exports = router;
