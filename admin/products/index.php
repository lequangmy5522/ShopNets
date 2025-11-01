<?php 
$pageTitle = 'ShopNets';
$currentPage = 'products';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
?>
<link rel="stylesheet" href="../assets/css/pages/products.css">

  <section class="content products-page">
    <h1>Products Management</h1>
      <div class="content-header">
        <span>Manage your product catalog</span>
        <span>
            <button class="btn btn-primary">
              <img src="../assets/images/icons/add.png" alt="Add" style="width: 20px;">
              Add New Product
            </button>
        </span>
      </div>

      <div class="card filter-card">
        <div class="filter-header">Search &amp; Filter Products</div>
        <div class="filters-row">
          <div class="search-box">
            <input type="text" placeholder="Search Products...">
          </div>
          <div class="select">
            <select>
              <option selected>Category</option>
              <option>Phones</option>
              <option>Laptops</option>
              <option>Accessories</option>
            </select>
          </div>
        </div>
      </div>

      <div class="card">
        <div class="card-header">
          <h2>All Products</h2>
        </div>
        
        <div class="table-container">
          <table class="data-table">
            <thead>
              <tr>
                <th>ID</th>
                <th>Product Name</th>
                <th>Category</th>
                <th>Price</th>
                <th>Inventory</th>
                <th>Actions</th>
              </tr>
            </thead>
            <tbody>
              <tr>
                <td>1</td>
                <!-- <td><img src="../assets/images/uploads/product-sample.jpg" alt="Product" style="width: 50px; height: 50px; object-fit: cover; border-radius: 4px;"></td> -->
                <td>Sample Product</td>
                <td>Electronics</td>
                <td>500,000 VNĐ</td>
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
