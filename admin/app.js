// ==========================================================================
// BUDGETERRA ADMIN JAVASCRIPT CONTROLLER
// ==========================================================================

const API_BASE_URL = 'http://localhost:3000/api';

// Application State
const state = {
  users: [],
  transactions: [],
  remittances: [],
  stats: null,
  activeSection: 'dashboard',
  selectedUserIdForBudgets: null,
  selectedUserIdForAnalytics: null,
  analyticsPeriod: 'week'
};

// Chart.js instances (tracked to destroy/refresh)
let trendChartInstance = null;
let categoryChartInstance = null;

// DOM Elements
const elements = {
  sectionTitle: document.getElementById('section-title'),
  sectionSubtitle: document.getElementById('section-subtitle'),
  apiStatusText: document.getElementById('api-status-text'),
  apiStatusDot: document.querySelector('.api-status-badge .status-dot'),
  refreshAllBtn: document.getElementById('refresh-all-btn'),
  navItems: document.querySelectorAll('.nav-item'),
  sections: document.querySelectorAll('.content-section'),
  
  // Dashboard elements
  statsTotalUsers: document.getElementById('stats-total-users'),
  statsTotalTxs: document.getElementById('stats-total-txs'),
  statsTxVolume: document.getElementById('stats-tx-volume'),
  statsTotalIncome: document.getElementById('stats-total-income'),
  statsAvgBalance: document.getElementById('stats-avg-balance'),
  statsTotalExpense: document.getElementById('stats-total-expense'),
  statsRemitCount: document.getElementById('stats-remit-count'),
  dashboardRecentTxsBody: document.getElementById('dashboard-recent-txs-body'),
  perfReserves: document.getElementById('perf-reserves'),
  perfRemitted: document.getElementById('perf-remitted'),
  perfRemittedBar: document.getElementById('perf-remitted-bar'),
  perfRatio: document.getElementById('perf-ratio'),
  perfRatioBar: document.getElementById('perf-ratio-bar'),

  // Users elements
  usersTableBody: document.getElementById('users-table-body'),
  usersSearchInput: document.getElementById('users-search-input'),
  usersBadgeCount: document.getElementById('users-badge-count'),

  // Transactions elements
  txsTableBody: document.getElementById('txs-table-body'),
  txFilterUser: document.getElementById('tx-filter-user'),
  txFilterType: document.getElementById('tx-filter-type'),
  txFilterCategory: document.getElementById('tx-filter-category'),
  txsBadgeCount: document.getElementById('txs-badge-count'),

  // Budgets elements
  budgetsFilterUser: document.getElementById('budgets-filter-user'),
  budgetsBadgeCount: document.getElementById('budgets-badge-count'),
  budgetsContainer: document.getElementById('budgets-container'),

  // Remittances elements
  remitTableBody: document.getElementById('remit-table-body'),
  remitFilterUser: document.getElementById('remit-filter-user'),
  remitBadgeCount: document.getElementById('remit-badge-count'),

  // Analytics elements
  analyticsFilterUser: document.getElementById('analytics-filter-user'),
  periodButtons: document.querySelectorAll('.period-toggle .toggle-btn'),
  categoryLegend: document.getElementById('category-legend')
};

// ==========================================================================
// CORE INITIALIZATION & API CONNECTION
// ==========================================================================

document.addEventListener('DOMContentLoaded', () => {
  setupNavigation();
  setupEventListeners();
  checkApiHealth().then(online => {
    if (online) {
      loadAllData();
    }
  });
});

// Periodic API Health Checks
async function checkApiHealth() {
  try {
    const res = await fetch(`${API_BASE_URL}/health`);
    if (res.ok) {
      elements.apiStatusText.textContent = 'ONLINE';
      elements.apiStatusDot.className = 'status-dot online';
      return true;
    }
  } catch (e) {
    // API offline
  }
  elements.apiStatusText.textContent = 'OFFLINE';
  elements.apiStatusDot.className = 'status-dot offline';
  return false;
}

setInterval(checkApiHealth, 10000); // Check every 10s

// ==========================================================================
// NAVIGATION HANDLERS
// ==========================================================================

function setupNavigation() {
  elements.navItems.forEach(item => {
    item.addEventListener('click', (e) => {
      e.preventDefault();
      const section = item.getAttribute('data-section');
      switchSection(section);
    });
  });
}

function switchSection(sectionId) {
  // Update state
  state.activeSection = sectionId;

  // Update navbar items classes
  elements.navItems.forEach(item => {
    if (item.getAttribute('data-section') === sectionId) {
      item.classList.add('active');
    } else {
      item.classList.remove('active');
    }
  });

  // Toggle active content divs
  elements.sections.forEach(section => {
    if (section.id === `section-${sectionId}`) {
      section.classList.add('active');
    } else {
      section.classList.remove('active');
    }
  });

  // Update page header texts
  const titles = {
    dashboard: { title: 'Dashboard', subtitle: 'Real-time platform metrics and financial activity' },
    users: { title: 'User Accounts', subtitle: 'Manage registered members and monitor their balances' },
    transactions: { title: 'Transaction Ledger', subtitle: 'View, filter, and audit ledger entries across all accounts' },
    budgets: { title: 'Budget Control', subtitle: 'Category limits and threshold warnings' },
    remittances: { title: 'Remittance Transfers', subtitle: 'Manage international transfers and approve payment execution' },
    analytics: { title: 'Financial Analytics', subtitle: 'Category splits and historical trends' }
  };

  const header = titles[sectionId] || { title: 'Admin Panel', subtitle: '' };
  elements.sectionTitle.textContent = header.title;
  elements.sectionSubtitle.textContent = header.subtitle;

  // Load section-specific dependencies
  if (sectionId === 'budgets' && state.selectedUserIdForBudgets) {
    loadUserBudgets(state.selectedUserIdForBudgets);
  } else if (sectionId === 'analytics') {
    // Default to first user if none selected
    if (!state.selectedUserIdForAnalytics && state.users.length > 0) {
      state.selectedUserIdForAnalytics = state.users[0].id;
      elements.analyticsFilterUser.value = state.users[0].id;
    }
    loadUserAnalytics(state.selectedUserIdForAnalytics);
  }
}

// ==========================================================================
// DATA RETRIEVAL (FETCH API)
// ==========================================================================

async function loadAllData() {
  console.log('Fetching system state...');
  try {
    // 1. Fetch Admin Stats (Platform Overview)
    const statsRes = await fetch(`${API_BASE_URL}/admin/stats`);
    state.stats = await statsRes.json();
    
    // 2. Fetch Users List
    const usersRes = await fetch(`${API_BASE_URL}/admin/users`);
    state.users = await usersRes.json();

    // 3. Fetch Transactions
    const txsRes = await fetch(`${API_BASE_URL}/admin/transactions`);
    state.transactions = await txsRes.json();

    // 4. Fetch Remittances
    const remitRes = await fetch(`${API_BASE_URL}/admin/remittances`);
    state.remittances = await remitRes.json();

    // Bind state to elements
    renderDashboard();
    renderUsers();
    renderTransactions();
    renderRemittances();
    populateDropdowns();

    console.log('Data synchronization complete!');
  } catch (error) {
    console.error('Error synchronizing database content:', error);
  }
}

// ==========================================================================
// RENDER METHODS
// ==========================================================================

// 1. Render Dashboard
function renderDashboard() {
  if (!state.stats) return;

  const s = state.stats;
  elements.statsTotalUsers.textContent = s.total_users;
  elements.statsTotalTxs.textContent = s.total_transactions;
  elements.statsTxVolume.textContent = `$${formatAmount(s.total_volume)} Vol`;
  elements.statsTotalIncome.textContent = `$${formatAmount(s.total_income)}`;
  elements.statsAvgBalance.textContent = `Avg Bal: $${formatAmount(s.avg_user_balance)}`;
  elements.statsTotalExpense.textContent = `$${formatAmount(s.total_expense)}`;
  elements.statsRemitCount.textContent = `${s.total_remittances} Remittances`;

  // System Reserves (Sum of all user balances)
  elements.perfReserves.textContent = `$${formatAmount(s.total_user_balance)}`;

  // Remitted outflow progress
  elements.perfRemitted.textContent = `$${formatAmount(s.total_remitted_amount)}`;
  const remittedRatio = s.total_volume > 0 ? (s.total_remitted_amount / s.total_volume) * 100 : 0;
  elements.perfRemittedBar.style.width = `${Math.min(remittedRatio, 100)}%`;

  // Expense to Income Ratio
  const ratio = s.total_income > 0 ? (s.total_expense / s.total_income) * 100 : 0;
  elements.perfRatio.textContent = `${ratio.toFixed(1)}%`;
  elements.perfRatioBar.style.width = `${Math.min(ratio, 100)}%`;

  // Recent activity table
  let html = '';
  if (s.recent_transactions.length === 0) {
    html = `<tr><td colspan="6" class="text-center">No platform transactions recorded</td></tr>`;
  } else {
    s.recent_transactions.forEach(tx => {
      const isInc = tx.is_income === 1;
      const amtClass = isInc ? 'text-success' : 'text-danger';
      const badgeClass = tx.status === 'Success' ? 'badge-success' : tx.status === 'Pending' ? 'badge-pending' : 'badge-failed';
      
      html += `
        <tr>
          <td>
            <div class="user-info-cell">
              <span class="username">${escapeHTML(tx.user_name)}</span>
              <span class="email">${escapeHTML(tx.user_email)}</span>
            </div>
          </td>
          <td>
            <div class="user-info-cell">
              <span class="username">${escapeHTML(tx.title)}</span>
              <span class="email">${escapeHTML(tx.subtitle)}</span>
            </div>
          </td>
          <td>${escapeHTML(tx.category)}</td>
          <td class="${amtClass} font-semibold">${isInc ? '+' : '-'}$${formatAmount(tx.amount)}</td>
          <td>${formatDate(tx.date)}</td>
          <td><span class="badge ${badgeClass}">${tx.status}</span></td>
        </tr>
      `;
    });
  }
  elements.dashboardRecentTxsBody.innerHTML = html;
}

// 2. Render Users list
function renderUsers() {
  const query = elements.usersSearchInput.value.toLowerCase().trim();
  
  // Filter search
  const filteredUsers = state.users.filter(u => 
    u.name.toLowerCase().includes(query) || 
    u.email.toLowerCase().includes(query) || 
    u.account_number.toLowerCase().includes(query)
  );

  elements.usersBadgeCount.textContent = `${filteredUsers.length} Users`;

  let html = '';
  if (filteredUsers.length === 0) {
    html = `<tr><td colspan="8" class="text-center">No users matched your query</td></tr>`;
  } else {
    filteredUsers.forEach(u => {
      html += `
        <tr>
          <td class="font-semibold">${escapeHTML(u.name)}</td>
          <td>${escapeHTML(u.email)}</td>
          <td>${escapeHTML(u.phone) || '<span class="text-muted">N/A</span>'}</td>
          <td><code style="color:var(--accent-purple); font-weight:600;">${escapeHTML(u.account_number)}</code></td>
          <td class="font-semibold text-success">$${formatAmount(u.balance)}</td>
          <td><span class="badge badge-blue">${u.transactions_count} txs</span></td>
          <td>${formatDate(u.created_at)}</td>
          <td>
            <button class="action-btn-danger" onclick="deleteUser(${u.id}, '${escapeQuote(u.name)}')">
              <span class="material-icons-round" style="font-size:1rem;">delete</span>
              Delete
            </button>
          </td>
        </tr>
      `;
    });
  }
  elements.usersTableBody.innerHTML = html;
}

// 3. Render Transactions with dynamic filters
function renderTransactions() {
  const userId = elements.txFilterUser.value;
  const type = elements.txFilterType.value;
  const category = elements.txFilterCategory.value;

  let filtered = state.transactions;

  if (userId) {
    filtered = filtered.filter(t => t.user_id == userId);
  }
  if (type) {
    const isIncomeTarget = type === 'income' ? 1 : 0;
    filtered = filtered.filter(t => t.is_income === isIncomeTarget);
  }
  if (category) {
    filtered = filtered.filter(t => t.category === category);
  }

  elements.txsBadgeCount.textContent = `${filtered.length} Transactions`;

  let html = '';
  if (filtered.length === 0) {
    html = `<tr><td colspan="8" class="text-center">No transactions match the selected filters</td></tr>`;
  } else {
    filtered.forEach(t => {
      const isInc = t.is_income === 1;
      const amtClass = isInc ? 'text-success' : 'text-danger';
      const badgeClass = t.status === 'Success' ? 'badge-success' : t.status === 'Pending' ? 'badge-pending' : 'badge-failed';

      html += `
        <tr>
          <td>
            <div class="user-info-cell">
              <span class="username">${escapeHTML(t.user_name)}</span>
              <span class="email">${escapeHTML(t.user_email)}</span>
            </div>
          </td>
          <td class="font-semibold">${escapeHTML(t.title)}</td>
          <td class="text-muted">${escapeHTML(t.subtitle) || ''}</td>
          <td class="${amtClass} font-semibold">${isInc ? '+' : '-'}$${formatAmount(t.amount)}</td>
          <td>${escapeHTML(t.category)}</td>
          <td>${escapeHTML(t.account)}</td>
          <td><span class="badge ${badgeClass}">${t.status}</span></td>
          <td>${formatDate(t.date)}</td>
        </tr>
      `;
    });
  }
  elements.txsTableBody.innerHTML = html;
}

// 4. Render Remittances
function renderRemittances() {
  const userId = elements.remitFilterUser.value;
  let filtered = state.remittances;

  if (userId) {
    filtered = filtered.filter(r => r.user_id == userId);
  }

  elements.remitBadgeCount.textContent = `${filtered.length} Remittances`;

  let html = '';
  if (filtered.length === 0) {
    html = `<tr><td colspan="6" class="text-center">No remittances found</td></tr>`;
  } else {
    filtered.forEach(r => {
      const pendingSelected = r.status === 'Pending' ? 'selected' : '';
      const successSelected = r.status === 'Successful' ? 'selected' : '';
      const failedSelected = r.status === 'Failed' ? 'selected' : '';

      html += `
        <tr>
          <td>
            <div class="user-info-cell">
              <span class="username">${escapeHTML(r.user_name)}</span>
              <span class="email">${escapeHTML(r.user_email)}</span>
            </div>
          </td>
          <td class="font-semibold">${escapeHTML(r.recipient)}</td>
          <td class="font-semibold text-danger">-$${formatAmount(r.amount)}</td>
          <td>${formatDate(r.date)}</td>
          <td>
            <div class="select-wrapper status-select-container">
              <select class="status-select" onchange="updateRemitStatus(${r.id}, this.value)">
                <option value="Pending" ${pendingSelected}>Pending</option>
                <option value="Successful" ${successSelected}>Successful</option>
                <option value="Failed" ${failedSelected}>Failed</option>
              </select>
            </div>
          </td>
          <td>
            <span class="text-muted" style="font-size: 0.8rem;">Auto-adjusts user balance</span>
          </td>
        </tr>
      `;
    });
  }
  elements.remitTableBody.innerHTML = html;
}

// 5. Render Budget Meters for Selected User
async function loadUserBudgets(userId) {
  state.selectedUserIdForBudgets = userId;
  
  if (!userId) {
    elements.budgetsContainer.innerHTML = `
      <div class="no-data-placeholder">
        <span class="material-icons-round">pie_chart_outline</span>
        <p>Please select a user to view their active budgets and spending limit meters.</p>
      </div>
    `;
    elements.budgetsBadgeCount.textContent = '0 Budgets';
    return;
  }

  try {
    const res = await fetch(`${API_BASE_URL}/admin/users/${userId}/budgets`);
    const budgets = await res.json();

    elements.budgetsBadgeCount.textContent = `${budgets.length} Budgets`;

    if (budgets.length === 0) {
      elements.budgetsContainer.innerHTML = `
        <div class="no-data-placeholder">
          <span class="material-icons-round">folder_open</span>
          <p>This user has no budgets set up.</p>
        </div>
      `;
      return;
    }

    let html = '';
    budgets.forEach(b => {
      const percentage = b.limit_amount > 0 ? (b.spent / b.limit_amount) * 100 : 0;
      let statusClass = 'normal';
      if (percentage >= 90) statusClass = 'danger';
      else if (percentage >= 70) statusClass = 'warning';

      html += `
        <div class="budget-meter-card">
          <div class="budget-meter-header">
            <div class="budget-category-info">
              <div class="category-icon-bg ${b.color || 'blue'}">
                <span class="material-icons-round">${b.icon || 'folder'}</span>
              </div>
              <span class="budget-category-name">${escapeHTML(b.category)}</span>
            </div>
            <span class="budget-percentage ${statusClass}">${percentage.toFixed(0)}%</span>
          </div>

          <div class="meter-progress-container">
            <div class="meter-progress-fill ${statusClass}" style="width: ${Math.min(percentage, 100)}%;"></div>
          </div>

          <div class="budget-meter-details">
            <span>Spent: <strong>$${formatAmount(b.spent)}</strong></span>
            <span>Limit: <strong>$${formatAmount(b.limit_amount)}</strong></span>
          </div>
        </div>
      `;
    });
    elements.budgetsContainer.innerHTML = html;
  } catch (error) {
    console.error('Error fetching budgets:', error);
    elements.budgetsContainer.innerHTML = `<p class="text-danger text-center">Failed to load budgets</p>`;
  }
}

// 6. Load and Render Analytics Charts (Doughnut & Trends)
async function loadUserAnalytics(userId) {
  state.selectedUserIdForAnalytics = userId;

  if (!userId) return;

  try {
    // Fetch Category Breakdown
    const breakdownRes = await fetch(`${API_BASE_URL}/admin/users/${userId}/analytics/breakdown`);
    const breakdownData = await breakdownRes.json();

    // Fetch Trends Chart Data
    const chartRes = await fetch(`${API_BASE_URL}/admin/users/${userId}/analytics/chart?period=${state.analyticsPeriod}`);
    const chartData = await chartRes.json();

    renderCategoryChart(breakdownData);
    renderTrendChart(chartData);

  } catch (error) {
    console.error('Error loading analytics:', error);
  }
}

function renderCategoryChart(data) {
  const ctx = document.getElementById('categoryChart').getContext('2d');

  // Clear previous instance
  if (categoryChartInstance) {
    categoryChartInstance.destroy();
  }

  // Populate Custom Legend
  let legendHtml = '';
  if (data.categories.length === 0) {
    legendHtml = '<p class="text-muted text-center" style="grid-column:1/-1;">No expense split available</p>';
    elements.categoryLegend.innerHTML = legendHtml;
    
    // Draw empty chart
    categoryChartInstance = new Chart(ctx, {
      type: 'doughnut',
      data: {
        labels: ['No Data'],
        datasets: [{
          data: [1],
          backgroundColor: ['#1e293b'],
          borderWidth: 0
        }]
      },
      options: { cutout: '75%', plugins: { legend: { display: false } } }
    });
    return;
  }

  const chartLabels = [];
  const chartDataValues = [];
  const chartColors = [];

  const cssColors = {
    orange: '#f59e0b',
    blue: '#3b82f6',
    green: '#10b981',
    red: '#f43f5e',
    purple: '#6366f1',
    pink: '#ec4899',
    indigo: '#4f46e5'
  };

  data.categories.forEach(cat => {
    const colCode = cssColors[cat.color] || cssColors.blue;
    chartLabels.push(cat.category);
    chartDataValues.push(cat.total);
    chartColors.push(colCode);

    legendHtml += `
      <div class="legend-item">
        <div class="legend-item-left">
          <span class="legend-color-dot" style="background-color: ${colCode};"></span>
          <span>${escapeHTML(cat.category)}</span>
        </div>
        <div class="legend-item-right">
          <span>$${formatAmount(cat.total)}</span>
          <span class="legend-percentage">${cat.percentage}%</span>
        </div>
      </div>
    `;
  });
  elements.categoryLegend.innerHTML = legendHtml;

  categoryChartInstance = new Chart(ctx, {
    type: 'doughnut',
    data: {
      labels: chartLabels,
      datasets: [{
        data: chartDataValues,
        backgroundColor: chartColors,
        borderWidth: 0,
        hoverOffset: 4
      }]
    },
    options: {
      cutout: '70%',
      responsive: true,
      maintainAspectRatio: false,
      plugins: {
        legend: {
          display: false
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return ` ${context.label}: $${formatAmount(context.parsed)}`;
            }
          }
        }
      }
    }
  });
}

function renderTrendChart(data) {
  const ctx = document.getElementById('trendChart').getContext('2d');

  if (trendChartInstance) {
    trendChartInstance.destroy();
  }

  const labels = data.map(d => d.label);
  const incomeValues = data.map(d => d.income);
  const expenseValues = data.map(d => d.expense);

  trendChartInstance = new Chart(ctx, {
    type: 'line',
    data: {
      labels: labels,
      datasets: [
        {
          label: 'Income Flow',
          data: incomeValues,
          borderColor: '#10b981',
          backgroundColor: 'rgba(16, 185, 129, 0.05)',
          fill: true,
          tension: 0.35,
          borderWidth: 3,
          pointBackgroundColor: '#10b981'
        },
        {
          label: 'Expense Flow',
          data: expenseValues,
          borderColor: '#f43f5e',
          backgroundColor: 'rgba(244, 63, 94, 0.05)',
          fill: true,
          tension: 0.35,
          borderWidth: 3,
          pointBackgroundColor: '#f43f5e'
        }
      ]
    },
    options: {
      responsive: true,
      maintainAspectRatio: false,
      scales: {
        y: {
          grid: {
            color: 'rgba(255, 255, 255, 0.05)'
          },
          ticks: {
            color: '#9ca3af',
            callback: function(value) {
              return '$' + formatAmount(value);
            }
          }
        },
        x: {
          grid: {
            display: false
          },
          ticks: {
            color: '#9ca3af'
          }
        }
      },
      plugins: {
        legend: {
          position: 'top',
          labels: {
            color: '#f3f4f6',
            font: {
              family: 'Outfit'
            }
          }
        },
        tooltip: {
          callbacks: {
            label: function(context) {
              return ` ${context.dataset.label}: $${formatAmount(context.parsed.y)}`;
            }
          }
        }
      }
    }
  });
}

// ==========================================================================
// DROPDOWN SETUP & DOM BINDINGS
// ==========================================================================

function populateDropdowns() {
  // Clear options except first
  const clearDropdown = (selectEl, defaultText) => {
    selectEl.innerHTML = `<option value="">${defaultText}</option>`;
  };

  clearDropdown(elements.txFilterUser, 'All Users');
  clearDropdown(elements.budgetsFilterUser, 'Select a user...');
  clearDropdown(elements.remitFilterUser, 'All Users');
  elements.analyticsFilterUser.innerHTML = '';

  state.users.forEach(u => {
    const optText = `${u.name} (${u.email})`;
    
    // Transactions User filter
    const optTx = new Option(optText, u.id);
    elements.txFilterUser.add(optTx);

    // Budgets User filter
    const optBud = new Option(optText, u.id);
    elements.budgetsFilterUser.add(optBud);

    // Remittances User filter
    const optRem = new Option(optText, u.id);
    elements.remitFilterUser.add(optRem);

    // Analytics User filter
    const optAn = new Option(optText, u.id);
    elements.analyticsFilterUser.add(optAn);
  });

  // Restore values if in state
  if (state.selectedUserIdForBudgets) {
    elements.budgetsFilterUser.value = state.selectedUserIdForBudgets;
  }
  if (state.selectedUserIdForAnalytics) {
    elements.analyticsFilterUser.value = state.selectedUserIdForAnalytics;
  }
}

function setupEventListeners() {
  // Refresh button
  elements.refreshAllBtn.addEventListener('click', () => {
    checkApiHealth().then(online => {
      if (online) loadAllData();
    });
  });

  // Search user
  elements.usersSearchInput.addEventListener('input', () => {
    renderUsers();
  });

  // Transactions filters
  elements.txFilterUser.addEventListener('change', renderTransactions);
  elements.txFilterType.addEventListener('change', renderTransactions);
  elements.txFilterCategory.addEventListener('change', renderTransactions);

  // Budgets filter
  elements.budgetsFilterUser.addEventListener('change', (e) => {
    loadUserBudgets(e.target.value);
  });

  // Remittances filter
  elements.remitFilterUser.addEventListener('change', renderRemittances);

  // Analytics filters
  elements.analyticsFilterUser.addEventListener('change', (e) => {
    loadUserAnalytics(e.target.value);
  });

  // Analytics period toggle
  elements.periodButtons.forEach(btn => {
    btn.addEventListener('click', (e) => {
      elements.periodButtons.forEach(b => b.classList.remove('active'));
      btn.classList.add('active');
      state.analyticsPeriod = btn.getAttribute('data-period');
      loadUserAnalytics(state.selectedUserIdForAnalytics);
    });
  });
}

// ==========================================================================
// ADMINISTRATIVE FUNCTIONS (ACTIONS)
// ==========================================================================

// 1. Delete user account
async function deleteUser(id, name) {
  const confirmDelete = confirm(`Are you absolutely sure you want to delete the user account for "${name}"?\nThis will permanently purge their transactions, category budgets, and remittances from the platform ledger. This action is irreversible.`);
  
  if (!confirmDelete) return;

  try {
    const res = await fetch(`${API_BASE_URL}/admin/users/${id}`, {
      method: 'DELETE'
    });

    if (res.ok) {
      alert(`User "${name}" has been deleted.`);
      
      // Reset variables if that user was selected
      if (state.selectedUserIdForBudgets == id) state.selectedUserIdForBudgets = null;
      if (state.selectedUserIdForAnalytics == id) state.selectedUserIdForAnalytics = null;

      loadAllData();
    } else {
      const data = await res.json();
      alert(`Delete failed: ${data.message || 'Unknown error'}`);
    }
  } catch (error) {
    console.error('Delete API error:', error);
    alert('Failed to connect to backend to delete user.');
  }
}

// 2. Modify remittance status (re-triggers user balance calculations)
async function updateRemitStatus(id, newStatus) {
  try {
    const res = await fetch(`${API_BASE_URL}/admin/remittances/${id}/status`, {
      method: 'PUT',
      headers: {
        'Content-Type': 'application/json'
      },
      body: JSON.stringify({ status: newStatus })
    });

    if (res.ok) {
      // Refresh local cache and UI elements
      loadAllData();
    } else {
      const data = await res.json();
      alert(`Failed to update status: ${data.message || 'Unknown error'}`);
    }
  } catch (error) {
    console.error('Status modification API error:', error);
    alert('Failed to connect to backend to update remittance status.');
  }
}

// ==========================================================================
// STRING & VALUE FORMATTING HELPERS
// ==========================================================================

function formatAmount(val) {
  if (val === undefined || val === null || isNaN(val)) return '0.00';
  return parseFloat(val).toLocaleString('en-US', {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2
  });
}

function formatDate(dateStr) {
  if (!dateStr) return '';
  const d = new Date(dateStr);
  if (isNaN(d.getTime())) return dateStr;
  return d.toLocaleDateString('en-US', {
    year: 'numeric',
    month: 'short',
    day: 'numeric'
  });
}

function escapeHTML(str) {
  if (!str) return '';
  return str
    .replace(/&/g, '&amp;')
    .replace(/</g, '&lt;')
    .replace(/>/g, '&gt;')
    .replace(/"/g, '&quot;')
    .replace(/'/g, '&#039;');
}

function escapeQuote(str) {
  if (!str) return '';
  return str.replace(/'/g, "\\'");
}
