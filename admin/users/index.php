<?php 
$pageTitle = 'ShopNets';
$currentPage = 'users';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
?>
<link rel="stylesheet" href="../assets/css/pages/users.css">

    <section class="content users-page">
      <div class="content-header">
        <h1>Users Management</h1>
        <button class="btn btn-primary">
          Add New User
        </button>
      </div>
      
      <div class="page-subtitle">
        Manage your Users base
      </div>

      <!-- Search & Filter -->
      <div class="users-filter-card">
        <div class="users-filter-header">Search & Filter Users</div>
        <div class="users-search-container">
          <div class="users-search-box">
            <input type="text" placeholder="Search Products...">
          </div>
        </div>
      </div>

      <!-- Users Table -->
      <div class="users-table-card">
        <div class="users-table-header">
          <h2>All Users</h2>
        </div>
        
        <div class="users-table-container">
          <table class="users-data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Users</th>
                <th>Email</th>
                <th>Date created</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>1</td>
                <td>Nguyen Van A</td>
                <td>Example@gmail.com</td>
                <td>11/10/2025</td>
                <td>
                  <button class="users-btn-icon users-btn-edit" title="Edit">
                    <img src="../assets/images/icons/edit.png" alt="Edit" style="width: 16px;">
                  </button>
                  <button class="users-btn-icon users-btn-delete" title="Delete">
                    <img src="../assets/images/icons/delete.png" alt="Delete" style="width: 16px;">
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

<?php include '../includes/footer.php'; ?>
