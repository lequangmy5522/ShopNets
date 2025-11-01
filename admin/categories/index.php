<?php 
$pageTitle = 'ShopNets';
$currentPage = 'categories';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
?>
<link rel="stylesheet" href="../assets/css/pages/categories.css">

  <section class="content categories-page">
      <div class="content-header">
        <h1>Categories Management</h1>
        <button class="btn btn-primary" onclick="window.location.href='add_category.php'">
          <img src="../assets/images/icons/add.png" alt="Add">
          Add New Category
        </button>
      </div>

      <div class="card">
        <div class="card-header">
          <h2>All Categories</h2>
          <div class="search-box">
            <input type="text" placeholder="Search categories...">
          </div>
        </div>
        
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Category Name</th>
                <th>Description</th>
                <th>Products Count</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>1</td>
                <td>Phone</td>
                <td>Mobile products</td>
                <td>100</td>
                <td>
                  <button class="btn-icon btn-edit" title="Edit">
                    <img src="../assets/images/icons/edit.png" alt="Edit" style="width: 18px;">
                  </button>
                  <button class="btn-icon btn-delete" title="Delete">
                    <img src="../assets/images/icons/delete.png" alt="Delete" style="width: 18px;">
                  </button>
                </td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </section>

<?php include '../includes/footer.php'; ?>
