  <aside class="sidebar">
    <div class="logo-area">
      <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/icons_logo/apple-icon-60x60.png" alt="ShopNets Logo">
      <span class="logo-text">ShopNets</span>
    </div>

    <div class="sidebar-content">
      <nav class="menu">
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>index.php" class="menu-item <?php echo (isset($currentPage) && $currentPage == 'dashboard') ? 'active' : ''; ?>">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Dashboard.png" alt="Dashboard">
          Dashboard
        </a>
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>products/index.php" class="menu-item <?php echo (isset($currentPage) && $currentPage == 'products') ? 'active' : ''; ?>">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Products.png" alt="Products">
          Products
        </a>
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>categories/index.php" class="menu-item <?php echo (isset($currentPage) && $currentPage == 'categories') ? 'active' : ''; ?>">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Categories.png" alt="Categories">
          Categories
        </a>
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>orders/index.php" class="menu-item <?php echo (isset($currentPage) && $currentPage == 'orders') ? 'active' : ''; ?>">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Orders.png" alt="Orders">
          Orders
        </a>
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>users/index.php" class="menu-item <?php echo (isset($currentPage) && $currentPage == 'users') ? 'active' : ''; ?>">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Users.png" alt="Users">
          Users
        </a>
      </nav>

      <div class="menu-bottom">
        <a href="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>settings/index.php" class="menu-item">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Setting.png" alt="Settings">
          Settings
        </a>
        <a href="#" class="menu-item" id="logoutBtn" onclick="handleLogout(event)">
          <img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/SignOut.png" alt="Sign Out">
          Sign Out
        </a>
      </div>
    </div>
  </aside>

  <main class="main">
    <header class="topbar">
      <div></div>
      <div class="actions">
        <span class="icon"><img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Notification.png" alt="Notifications"></span>
        <span class="icon"><img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Dark.png" alt="Theme"></span>
        <span class="icon"><img src="<?php echo isset($baseUrl) ? $baseUrl : ''; ?>assets/images/icons/Profile.png" alt="Profile"></span>
      </div>
    </header>
