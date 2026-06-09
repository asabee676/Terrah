const sqlite3 = require('sqlite3').verbose();
const path = require('path');
const bcrypt = require('bcryptjs');

const dbPath = path.join(__dirname, 'budgeterra.db');
const db = new sqlite3.Database(dbPath, (err) => {
  if (err) {
    console.error('Error opening database:', err.message);
  } else {
    console.log('Connected to SQLite database at:', dbPath);
  }
});

// Run serialized to make sure tables are created in order
db.serialize(() => {
  // 1. Users Table
  db.run(`
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password_hash TEXT NOT NULL,
      phone TEXT,
      account_number TEXT,
      balance REAL DEFAULT 0.0,
      created_at DATETIME DEFAULT CURRENT_TIMESTAMP
    )
  `);

  // 2. Transactions Table
  db.run(`
    CREATE TABLE IF NOT EXISTS transactions (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      subtitle TEXT,
      amount REAL NOT NULL,
      is_income INTEGER DEFAULT 0,
      category TEXT NOT NULL,
      account TEXT,
      status TEXT DEFAULT 'Success',
      date TEXT NOT NULL,
      icon TEXT,
      color TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // 3. Budgets Table
  db.run(`
    CREATE TABLE IF NOT EXISTS budgets (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      category TEXT NOT NULL,
      spent REAL DEFAULT 0.0,
      limit_amount REAL NOT NULL,
      icon TEXT,
      color TEXT,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  // 4. Remittances Table
  db.run(`
    CREATE TABLE IF NOT EXISTS remittances (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      recipient TEXT NOT NULL,
      amount REAL NOT NULL,
      status TEXT DEFAULT 'Pending',
      date TEXT NOT NULL,
      FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )
  `);

  console.log('Database tables verified/created successfully.');

  // Seed default data if users table is empty
  db.get('SELECT COUNT(*) as count FROM users', [], async (err, row) => {
    if (err) {
      console.error('Error checking users count:', err);
      return;
    }

    if (row.count === 0) {
      console.log('Database is empty. Seeding mock data...');
      
      const salt = await bcrypt.genSalt(10);
      const abelPasswordHash = await bcrypt.hash('password123', salt);
      const testUserPasswordHash = await bcrypt.hash('password123', salt);

      // Insert users
      db.run(
        `INSERT INTO users (name, email, password_hash, phone, account_number, balance) VALUES (?, ?, ?, ?, ?, ?)`,
        ['Abel', 'abel@budgeterra.com', abelPasswordHash, '+1234567890', 'BE-992-184-77', 15450.75],
        function (err) {
          if (err) {
            console.error('Error seeding Abel user:', err);
            return;
          }
          const abelId = this.lastID;
          console.log(`Seeded Abel user with ID ${abelId}`);

          // Seed Budgets for Abel
          const budgets = [
            { category: 'Food & Dining', spent: 345.50, limit_amount: 500.00, icon: 'restaurant', color: 'orange' },
            { category: 'Shopping', spent: 120.00, limit_amount: 300.00, icon: 'shopping_bag', color: 'blue' },
            { category: 'Transportation', spent: 85.00, limit_amount: 150.00, icon: 'directions_car', color: 'green' },
            { category: 'Entertainment', spent: 190.00, limit_amount: 200.00, icon: 'sports_esports', color: 'red' },
            { category: 'Bills & Utilities', spent: 450.00, limit_amount: 500.00, icon: 'receipt_long', color: 'purple' }
          ];

          const stmtBudget = db.prepare(`INSERT INTO budgets (user_id, category, spent, limit_amount, icon, color) VALUES (?, ?, ?, ?, ?, ?)`);
          budgets.forEach(b => {
            stmtBudget.run(abelId, b.category, b.spent, b.limit_amount, b.icon, b.color);
          });
          stmtBudget.finalize();

          // Seed Transactions for Abel (expenses and income across recent dates)
          const now = new Date();
          const getDateStr = (offsetDays) => {
            const d = new Date(now);
            d.setDate(d.getDate() - offsetDays);
            return d.toISOString().split('T')[0];
          };

          const transactions = [
            { title: 'Salary Deposit', subtitle: 'Tech Corp Monthly', amount: 8500.00, is_income: 1, category: 'Salary', account: 'Main Account', status: 'Success', date: getDateStr(0), icon: 'work', color: 'green' },
            { title: 'Supermarket', subtitle: 'Weekly groceries', amount: 124.50, is_income: 0, category: 'Food & Dining', account: 'Visa Card', status: 'Success', date: getDateStr(1), icon: 'restaurant', color: 'orange' },
            { title: 'Uber Ride', subtitle: 'To downtown office', amount: 25.00, is_income: 0, category: 'Transportation', account: 'Visa Card', status: 'Success', date: getDateStr(2), icon: 'directions_car', color: 'green' },
            { title: 'Amazon Purchase', subtitle: 'Mechanical Keyboard', amount: 120.00, is_income: 0, category: 'Shopping', account: 'Mastercard', status: 'Success', date: getDateStr(3), icon: 'shopping_bag', color: 'blue' },
            { title: 'Netflix Subscription', subtitle: 'Monthly standard plan', amount: 15.50, is_income: 0, category: 'Entertainment', account: 'Visa Card', status: 'Success', date: getDateStr(4), icon: 'sports_esports', color: 'red' },
            { title: 'Electricity Bill', subtitle: 'Power & Gas Co.', amount: 150.00, is_income: 0, category: 'Bills & Utilities', account: 'Main Account', status: 'Success', date: getDateStr(5), icon: 'receipt_long', color: 'purple' },
            { title: 'Freelance Design', subtitle: 'Logo project payment', amount: 1200.00, is_income: 1, category: 'Freelance', account: 'Main Account', status: 'Success', date: getDateStr(6), icon: 'monetization_on', color: 'green' },
            { title: 'Dinner at Steakhouse', subtitle: 'Anniversary celebration', amount: 150.00, is_income: 0, category: 'Food & Dining', account: 'Mastercard', status: 'Success', date: getDateStr(7), icon: 'restaurant', color: 'orange' },
            { title: 'Gas Station', subtitle: 'Fuel top-up', amount: 60.00, is_income: 0, category: 'Transportation', account: 'Visa Card', status: 'Success', date: getDateStr(8), icon: 'directions_car', color: 'green' },
            { title: 'Gym Membership', subtitle: 'Monthly sub', amount: 50.00, is_income: 0, category: 'Entertainment', account: 'Visa Card', status: 'Success', date: getDateStr(10), icon: 'sports_esports', color: 'red' },
            { title: 'Internet Service', subtitle: 'Fiber broadband', amount: 80.00, is_income: 0, category: 'Bills & Utilities', account: 'Main Account', status: 'Success', date: getDateStr(12), icon: 'receipt_long', color: 'purple' },
            { title: 'Stock Dividend', subtitle: 'Global Tech Fund', amount: 350.00, is_income: 1, category: 'Investment', account: 'Main Account', status: 'Success', date: getDateStr(15), icon: 'trending_up', color: 'green' }
          ];

          const stmtTx = db.prepare(`
            INSERT INTO transactions (user_id, title, subtitle, amount, is_income, category, account, status, date, icon, color)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
          `);
          transactions.forEach(tx => {
            stmtTx.run(abelId, tx.title, tx.subtitle, tx.amount, tx.is_income, tx.category, tx.account, tx.status, tx.date, tx.icon, tx.color);
          });
          stmtTx.finalize();

          // Seed Remittances for Abel
          const remittances = [
            { recipient: 'John Doe', amount: 500.00, status: 'Successful', date: getDateStr(1) },
            { recipient: 'Alice Smith', amount: 1200.00, status: 'Pending', date: getDateStr(2) },
            { recipient: 'Bob Johnson', amount: 300.00, status: 'Failed', date: getDateStr(4) },
            { recipient: 'Michael Green', amount: 750.00, status: 'Successful', date: getDateStr(8) }
          ];

          const stmtRem = db.prepare(`
            INSERT INTO remittances (user_id, recipient, amount, status, date)
            VALUES (?, ?, ?, ?, ?)
          `);
          remittances.forEach(rem => {
            stmtRem.run(abelId, rem.recipient, rem.amount, rem.status, rem.date);
          });
          stmtRem.finalize();

          console.log('Seeded Abel user, budgets, transactions, and remittances successfully!');
        }
      );

      // Insert extra users for admin panel testing
      const extraUsers = [
        ['Sarah Jenkins', 'sarah@example.com', testUserPasswordHash, '+1987654321', 'BE-882-990-21', 4200.50],
        ['David Miller', 'david@example.com', testUserPasswordHash, '+1555123456', 'BE-771-334-11', 120.00],
        ['Emily Watson', 'emily@example.com', testUserPasswordHash, '+1444987654', 'BE-662-881-09', 24900.00]
      ];

      extraUsers.forEach(([name, email, hash, phone, accNum, bal]) => {
        db.run(
          `INSERT INTO users (name, email, password_hash, phone, account_number, balance) VALUES (?, ?, ?, ?, ?, ?)`,
          [name, email, hash, phone, accNum, bal],
          function (err) {
            if (err) {
              console.error(`Error seeding ${name}:`, err);
            } else {
              const uId = this.lastID;
              console.log(`Seeded extra user ${name} with ID ${uId}`);
              
              // Seed a few dummy transactions for these users
              db.run(`
                INSERT INTO transactions (user_id, title, subtitle, amount, is_income, category, account, status, date, icon, color)
                VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
              `, [uId, 'Initial Deposit', 'Welcome bonus', 1000.00, 1, 'Salary', 'Main Account', 'Success', new Date().toISOString().split('T')[0], 'work', 'green']);
            }
          }
        );
      });
    } else {
      console.log('Database already has users. Skipping seed.');
    }
  });
});

module.exports = db;
