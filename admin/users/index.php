<?php 
$pageTitle = 'ShopNets';
$currentPage = 'users';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
require_once '../includes/db_connect.php';
?>
<link rel="stylesheet" href="../assets/css/pages/users.css">

    <section class="content users-page">
      <div class="content-header">
        <h1>Users Management</h1>
      </div>
      
      <div class="page-subtitle">
        Manage your Users base
      </div>

      <div class="users-filter-card">
        <div class="users-filter-header">Search & Filter Users</div>
        <div class="users-search-container">
          <div class="users-search-box">
            <input type="text" id="searchInput" placeholder="Search Users...">
          </div>
        </div>
      </div>

      <div id="loadingIndicator" class="loading-indicator" style="display: none;">
        <div class="spinner"></div>
        Loading users...
      </div>

      <div class="users-table-card">
        <div class="users-table-header">
          <h2>All Users</h2>
        </div>
        
        <div class="users-table-container">
          <table id="usersTable" class="users-data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Username</th>
                <th>Email</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
            </tbody>
          </table>
        </div>
      </div>
    </section>

<div id="editUserModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>Edit User</h2>
      <span class="close" id="editModalClose">&times;</span>
    </div>
    <div class="modal-body">
      <form id="editUserForm">
        <input type="hidden" id="editUserId" name="id">
        <div class="form-group">
          <label for="editUsername">Username <span class="required">*</span></label>
          <input type="text" id="editUsername" name="username" required>
        </div>
        <div class="form-group">
          <label for="editEmail">Email <span class="required">*</span></label>
          <input type="email" id="editEmail" name="email" required>
        </div>
        <div class="error-messages" id="editErrorMessages"></div>
        <div class="form-actions">
          <button type="submit" class="btn btn-primary">
            <span class="btn-text">Update User</span>
            <span class="loading-spinner" style="display: none;">
              <img src="../assets/images/icons/loading.gif" alt="Loading..." style="width: 16px;">
            </span>
          </button>
          <button type="button" class="btn btn-secondary" id="editCancelBtn">Cancel</button>
        </div>
      </form>
    </div>
  </div>
</div>

<div id="deleteUserModal" class="modal">
  <div class="modal-content">
    <div class="modal-header">
      <h2>⚠️ Confirm Delete</h2>
      <span class="close" id="deleteModalClose">&times;</span>
    </div>
    <div class="modal-body">
      <input type="hidden" id="deleteUserId">
      <p>Are you sure you want to delete user "<strong id="deleteUserName"></strong>"?</p>
      <p style="color: #666; font-size: 14px; margin-bottom: 10px;">This action cannot be undone.</p>
      
      <div class="form-actions">
        <button type="button" id="confirmDelete" class="btn btn-primary delete-confirm-btn">
          <span class="btn-text">Delete User</span>
          <span class="loading-spinner" style="display: none;">
            <img src="../assets/images/icons/loading.gif" alt="Loading..." style="width: 16px;">
          </span>
        </button>
        <button type="button" class="btn btn-secondary" id="deleteCancelBtn">Cancel</button>
      </div>
    </div>
  </div>
</div>

<?php include '../includes/footer.php'; ?>

<script src="../assets/js/user.js"></script>
