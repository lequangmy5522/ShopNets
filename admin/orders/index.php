<?php 
$pageTitle = 'ShopNets';
$currentPage = 'orders';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
?>
<link rel="stylesheet" href="../assets/css/pages/orders.css">

  <section class="content orders-page">
      <div class="content-header">
        <h1>Orders Management</h1>
      </div>

      <section class="stats">
        <div class="card">
          <div class="card-header">
            <span>Orders Placed</span>
            <span class="icon">
            </span>
          </div>
          <div class="card-subtitle">New orders received</div>
          <div class="card-value blue">2</div>
        </div>

        <div class="card active">
          <div class="card-header">
            <span>Orders Shipped</span>
            <span class="icon">
            </span>
          </div>
          <div class="card-subtitle">Orders on the way</div>
          <div class="card-value green">2</div>
        </div>

        <div class="card">
          <div class="card-header">
            <span>Orders Returned</span>
            <span class="icon">
            </span>
          </div>
          <div class="card-subtitle">Returned orders</div>
          <div class="card-value red">1</div>
        </div>
      </section>

      <div class="card filter-card">
        <div class="filter-header">Search & Filter Orders</div>
        <div class="filters-row">
          <div class="search-box">
            <input type="text" placeholder="Search Products...">
          </div>
          <div class="select">
            <select>
              <option selected>Status</option>
              <option>Placed</option>
              <option>Shipped</option>
              <option>Returned</option>
            </select>
          </div>
          <div class="select">
            <select>
              <option selected>Date Range</option>
              <option>Last 7 days</option>
              <option>Last 30 days</option>
              <option>Last 90 days</option>
            </select>
          </div>
        </div>
      </div>

      <!-- Orders Table -->
      <div class="orders-table-card">
        <div class="orders-table-header">
          <h2>All Orders</h2>
          <div class="orders-tabs">
            <span class="orders-tab active">All Orders (5)</span>
            <span class="orders-tab">Placed (2)</span>
            <span class="orders-tab">Shipped (2)</span>
            <span class="orders-tab">Returned (1)</span>
          </div>
        </div>
        
        <div class="orders-table-container">
          <table class="orders-data-table">
            <thead>
              <tr>
                <th>Order ID</th>
                <th>Customer</th>
                <th>Products</th>
                <th>Total</th>
                <th>Status</th>
                <th>Date</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>ORD-001</td>
                <td>
                  <div class="orders-customer-info">
                    <strong>John Smith</strong>
                    <div class="orders-customer-email">john@example.com</div>
                  </div>
                </td>
                <td>3</td>
                <td>$299.99</td>
                <td><span class="orders-badge orders-badge-shipped">Shipped</span></td>
                <td>2024-01-15</td>
                <td>
                  <button class="orders-btn-icon orders-btn-view" title="View">
                    <img src="../assets/images/icons/view.png" alt="View" style="width: 18px;">
                  </button>
                </td>
              </tr>
              <tr>
                <td>ORD-002</td>
                <td>
                  <div class="orders-customer-info">
                    <strong>Sarah Johnson</strong>
                    <div class="orders-customer-email">sarah@example.com</div>
                  </div>
                </td>
                <td>1</td>
                <td>$89.99</td>
                <td><span class="orders-badge orders-badge-placed">Placed</span></td>
                <td>2024-01-16</td>
                <td>
                  <button class="orders-btn-icon orders-btn-view" title="View">
                    <img src="../assets/images/icons/view.png" alt="View" style="width: 18px;">
                  </button>
                </td>
              </tr>
              <tr>
                <td>ORD-003</td>
                <td>
                  <div class="orders-customer-info">
                    <strong>Mike Brown</strong>
                    <div class="orders-customer-email">mike@example.com</div>
                  </div>
                </td>
                <td>2</td>
                <td>$159.98</td>
                <td><span class="orders-badge orders-badge-returned">Returned</span></td>
                <td>2024-01-14</td>
                <td>
                  <button class="orders-btn-icon orders-btn-view" title="View">
                    <img src="../assets/images/icons/view.png" alt="View" style="width: 18px;">
                  </button>
                </td>
              </tr>
              <tr>
                <td>ORD-004</td>
                <td>
                  <div class="orders-customer-info">
                    <strong>Emily Davis</strong>
                    <div class="orders-customer-email">emily@example.com</div>
                  </div>
                </td>
                <td>1</td>
                <td>$49.99</td>
                <td><span class="orders-badge orders-badge-shipped">Shipped</span></td>
                <td>2024-01-17</td>
                <td>
                  <button class="orders-btn-icon orders-btn-view" title="View">
                    <img src="../assets/images/icons/view.png" alt="View" style="width: 18px;">
                  </button>
                </td>
              </tr>
              <tr>
                <td>ORD-005</td>
                <td>
                  <div class="orders-customer-info">
                    <strong>David Wilson</strong>
                    <div class="orders-customer-email">david@example.com</div>
                  </div>
                </td>
                <td>4</td>
                <td>$399.96</td>
                <td><span class="orders-badge orders-badge-placed">Placed</span></td>
                <td>2024-01-18</td>
                <td>
                  <button class="orders-btn-icon orders-btn-view" title="View">
                    <img src="../assets/images/icons/view.png" alt="View" style="width: 18px;">
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

<?php include '../includes/footer.php'; ?>
