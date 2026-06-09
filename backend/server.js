const express = require('express');
const cors = require('cors');
require('dotenv').config();

const db = require('./db'); // Initializes SQLite DB on startup

const app = express();
const PORT = process.env.PORT || 3000;

const path = require('path');

// Middleware
app.use(cors());
app.use(express.json());
app.use('/admin', express.static(path.join(__dirname, '../admin')));

// Routes Mounts
app.use('/api/auth', require('./routes/auth'));
app.use('/api/transactions', require('./routes/transactions'));
app.use('/api/budgets', require('./routes/budgets'));
app.use('/api/remittances', require('./routes/remittances'));
app.use('/api/analytics', require('./routes/analytics'));
app.use('/api/admin', require('./routes/admin'));

// Health Check / Root Endpoint
app.get('/api/health', (req, res) => {
  res.json({
    status: 'healthy',
    timestamp: new Date().toISOString(),
    database: 'SQLite',
    service: 'Budgeterra Backend'
  });
});

app.get('/', (req, res) => {
  res.send('Budgeterra API is running. Direct admin panel traffic to admin/index.html.');
});

// Start Server
app.listen(PORT, () => {
  console.log(`=========================================`);
  console.log(` BUDGETERRA BACKEND SERVER RUNNING       `);
  console.log(` Port: ${PORT}                            `);
  console.log(` Environment: development                 `);
  console.log(` URL: http://localhost:${PORT}             `);
  console.log(`=========================================`);
});
