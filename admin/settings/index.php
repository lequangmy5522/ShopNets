<?php 
$pageTitle = 'Settings | ShopNets';
$currentPage = 'settings';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';
?>

    <section class="content">
      <div class="content-header">
        <h1>Settings</h1>
      </div>

      <div class="card">
        <div class="card-header">
          <h2>General Settings</h2>
        </div>
        
        <div style="padding: 2rem;">
          <form>
            <div style="margin-bottom: 1.5rem;">
              <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Site Name</label>
              <input type="text" value="ShopNets" style="width: 100%; padding: 0.75rem; border: 1px solid #e5e7eb; border-radius: 8px;">
            </div>
            
            <div style="margin-bottom: 1.5rem;">
              <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Site Email</label>
              <input type="email" value="admin@shopnets.com" style="width: 100%; padding: 0.75rem; border: 1px solid #e5e7eb; border-radius: 8px;">
            </div>
            
            <div style="margin-bottom: 1.5rem;">
              <label style="display: block; margin-bottom: 0.5rem; font-weight: 500;">Currency</label>
              <select style="width: 100%; padding: 0.75rem; border: 1px solid #e5e7eb; border-radius: 8px;">
                <option value="VND">Vietnamese Dong (VNĐ)</option>
                <option value="USD">US Dollar ($)</option>
                <option value="EUR">Euro (€)</option>
              </select>
            </div>
            
            <button type="submit" class="btn btn-primary">Save Settings</button>
          </form>
        </div>
      </div>
    </section>

<?php include '../includes/footer.php'; ?>
