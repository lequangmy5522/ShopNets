<?php 
$pageTitle = 'ShopNets';
$currentPage = 'dashboard';
$baseUrl = '';
require_once 'login/auth_check.php';
include 'includes/header.php';
include 'includes/sidebar.php';
?>

    <section class="stats">
      <div class="card">
        <div class="card-header">
          <span>Total Products</span>
          <span class="icon">
            <img src="assets/images/icons/Total_Products.png" alt="Total Products">
          </span>
        </div>
        <div class="card-value">10,000</div>
      </div>

      <div class="card">
        <div class="card-header">
          <span>Total Orders</span>
          <span class="icon">
            <img src="assets/images/icons/Total_Orders.png" alt="Total Orders">
          </span>
        </div>
        <div class="card-value">8,743</div>
      </div>

      <div class="card">
        <div class="card-header">
          <span>Total Users</span>
          <span class="icon">
            <img src="assets/images/icons/Total_Users.png" alt="Total Users">
          </span>
        </div>
        <div class="card-value">4,657</div>
      </div>

      <div class="card">
        <div class="card-header">
          <span>Revenue</span>
          <span class="icon">
            <img src="assets/images/icons/Revenue.png" alt="Revenue">
          </span>
        </div>
        <div class="card-value">267,604 VNĐ</div>
      </div>
    </section>
  </main>

<?php include 'includes/footer.php'; ?>
