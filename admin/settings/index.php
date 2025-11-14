<?php 
$pageTitle = 'Cài Đặt Hệ Thống | ShopNets';
$currentPage = 'settings';
$baseUrl = '../';
include '../includes/header.php';
include '../includes/sidebar.php';

// Load current admin data
require_once '../includes/db_connect.php';
try {
    $stmt = $pdo->prepare("SELECT * FROM admin WHERE id = ?");
    $stmt->execute([$_SESSION['admin_id'] ?? 1]);
    $currentAdmin = $stmt->fetch(PDO::FETCH_ASSOC);
} catch(PDOException $e) {
    $currentAdmin = ['email' => '', 'phone' => '', 'avatar' => ''];
}
?>

<div class="settings-page">

    <section class="content">
      <div class="content-header">
        <h1>System Settings</h1>
        <span>Manage basic information and website configuration</span>
      </div>

      <!-- Admin Profile Settings -->
      <div class="card settings-card">
        <div class="card-header">
          <h2>👤 Administrator Information</h2>
        </div>
        
        <div class="settings-content">
          <form id="adminProfileForm" method="POST" action="settings_action.php" enctype="multipart/form-data">
            <input type="hidden" name="action" value="admin_profile">
            
            <div class="admin-profile-section">
              <div class="avatar-upload">
                <div class="current-avatar">
                  <img src="<?php echo !empty($currentAdmin['avatar']) ? '../' . $currentAdmin['avatar'] : '../assets/images/default-avatar.svg'; ?>" alt="Avatar" id="currentAvatar">
                  <div class="avatar-overlay">
                    <span>📷 Change</span>
                  </div>
                </div>
                <input type="file" id="adminAvatar" name="admin_avatar" accept="image/*" style="display: none;">
                <button type="button" class="btn btn-secondary" onclick="document.getElementById('adminAvatar').click()">Choose Profile Picture</button>
                <span class="field-help">JPG, PNG max 5MB. Recommended size: 200x200px</span>
              </div>

              <div class="settings-grid">
                <div class="form-group">
                  <label for="adminEmail">Login Email <span class="required">*</span></label>
                  <input type="email" id="adminEmail" name="admin_email" value="<?php echo htmlspecialchars($currentAdmin['email'] ?? ''); ?>" required>
                  <span class="field-help">This email is used to login to the system</span>
                </div>
                
                <div class="form-group">
                  <label for="adminPhone">Phone Number</label>
                  <input type="tel" id="adminPhone" name="admin_phone" value="<?php echo htmlspecialchars($currentAdmin['phone'] ?? ''); ?>">
                </div>
              </div>
            </div>
            
            <button type="submit" class="btn btn-primary">👤 Update Admin Information</button>
          </form>
        </div>
      </div>

      <!-- Website Information Settings -->
      <div class="card settings-card">
        <div class="card-header">
          <h2>🌐 Website Information</h2>
        </div>
        
        <div class="settings-content">
          <form id="websiteInfoForm" method="POST" action="settings_action.php">
            <input type="hidden" name="action" value="website_info">
            
            <div class="settings-grid">
              <div class="form-group">
                <label for="siteName">Website / Application Name <span class="required">*</span></label>
                <input type="text" id="siteName" name="site_name" value="ShopNets" required>
              </div>
              
              <div class="form-group">
                <label for="siteTagline">Slogan / Tagline</label>
                <input type="text" id="siteTagline" name="site_tagline" value="Your Online Shopping Destination" placeholder="Website slogan">
              </div>
              
              <div class="form-group">
                <label for="metaDescription">Short Description (Meta Description) <span class="required">*</span></label>
                <textarea id="metaDescription" name="meta_description" rows="3" required placeholder="Brief description of the website to display on Google and social media...">ShopNets - Leading online shopping platform with thousands of high-quality products and best services.</textarea>
              </div>
            
            </div>
            
            <button type="submit" class="btn btn-primary">💾 Save Website Information</button>
          </form>
        </div>
      </div>

      <!-- Contact Information Settings -->
      <div class="card settings-card">
        <div class="card-header">
          <h2>📞 Contact Information</h2>
        </div>
        
        <div class="settings-content">
          <form id="contactInfoForm" method="POST" action="settings_action.php">
            <input type="hidden" name="action" value="contact_info">
            
            <div class="settings-grid">
              <div class="form-group">
                <label for="contactEmail">System Email <span class="required">*</span></label>
                <input type="email" id="contactEmail" name="contact_email" value="admin@shopnets.com" required placeholder="Main system email">
                <span class="field-help">This email will be used for notifications and contact</span>
              </div>
              
              <div class="form-group">
                <label for="supportEmail">Support Email</label>
                <input type="email" id="supportEmail" name="support_email" value="support@shopnets.com" placeholder="Email for customer contact">
              </div>
              
              <div class="form-group">
                <label for="contactPhone">Phone Number <span class="required">*</span></label>
                <input type="tel" id="contactPhone" name="contact_phone" value="0123-456-789" required placeholder="Contact phone number">
              </div>
              
              <div class="form-group">
                <label for="contactHotline">Hotline</label>
                <input type="tel" id="contactHotline" name="contact_hotline" value="1900-1234" placeholder="24/7 support hotline">
              </div>
              
              <div class="form-group full-width">
                <label for="contactAddress">Contact Address <span class="required">*</span></label>
                <textarea id="contactAddress" name="contact_address" rows="3" required placeholder="Main office/store address...">123 ABC Street, XYZ Ward, District 1, Ho Chi Minh City, Vietnam</textarea>
              </div>
              
              <div class="form-group">
                <label for="workingHours">Working Hours</label>
                <input type="text" id="workingHours" name="working_hours" value="8:00 - 17:00, Monday - Sunday" placeholder="Example: 8:00 - 17:00, Mon-Sat">
              </div>
              
              <div class="form-group">
                <label for="website">Website</label>
                <input type="url" id="website" name="website" value="https://shopnets.com" placeholder="https://website.com">
              </div>
            </div>
            
            <button type="submit" class="btn btn-primary">📱 Update Contact Information</button>
          </form>
        </div>
      </div>

      <!-- System Settings -->
      <div class="card settings-card">
        <div class="card-header">
          <h2>⚙️ System Settings</h2>
        </div>
        
        <div class="settings-content">
          <form id="systemSettingsForm" method="POST" action="settings_action.php">
            <input type="hidden" name="action" value="system_settings">
            
            <div class="settings-grid">
              <div class="form-group">
                <label for="currency">Currency Unit <span class="required">*</span></label>
                <select id="currency" name="currency" required>
                  <option value="VND" selected>Vietnamese Dong (VNĐ)</option>
                  <option value="USD">US Dollar ($)</option>
                  <option value="EUR">Euro (€)</option>
                  <option value="JPY">Japanese Yen (¥)</option>
                </select>
              </div>
              
              <div class="form-group">
                <label for="timezone">Timezone</label>
                <select id="timezone" name="timezone">
                  <option value="Asia/Ho_Chi_Minh" selected>Vietnam (GMT+7)</option>
                  <option value="Asia/Bangkok">Thailand (GMT+7)</option>
                  <option value="Asia/Singapore">Singapore (GMT+8)</option>
                  <option value="UTC">UTC (GMT+0)</option>
                </select>
              </div>
              
              <div class="form-group">
                <label for="language">Language</label>
                <select id="language" name="language">
                  <option value="vi">Tiếng Việt</option>
                  <option value="en" selected>English</option>
                </select>
              </div>
              
              <div class="form-group">
                <label for="dateFormat">Date Format</label>
                <select id="dateFormat" name="date_format">
                  <option value="d/m/Y">DD/MM/YYYY</option>
                  <option value="m/d/Y" selected>MM/DD/YYYY</option>
                  <option value="Y-m-d">YYYY-MM-DD</option>
                </select>
              </div>
            </div>
            
            <button type="submit" class="btn btn-primary">⚙️ Save System Settings</button>
          </form>
        </div>
      </div>

    </section>
</div>

<script>
// Settings Page JavaScript
document.addEventListener('DOMContentLoaded', function() {
    // Handle avatar upload preview
    const avatarInput = document.getElementById('adminAvatar');
    const currentAvatar = document.getElementById('currentAvatar');
    
    if (avatarInput) {
        avatarInput.addEventListener('change', function(e) {
            const file = e.target.files[0];
            if (file) {
                const reader = new FileReader();
                reader.onload = function(e) {
                    currentAvatar.src = e.target.result;
                };
                reader.readAsDataURL(file);
            }
        });
    }
    
    // Handle form submissions with AJAX
    const forms = ['websiteInfoForm', 'contactInfoForm', 'adminProfileForm', 'systemSettingsForm'];
    
    forms.forEach(formId => {
        const form = document.getElementById(formId);
        if (form) {
            form.addEventListener('submit', function(e) {
                e.preventDefault();
                submitForm(this);
            });
        }
    });
});

function submitForm(form) {
    const submitBtn = form.querySelector('button[type="submit"]');
    const originalText = submitBtn.innerHTML;
    
    // Show loading state
    submitBtn.classList.add('loading');
    submitBtn.disabled = true;
    submitBtn.innerHTML = '⏳ Đang lưu...';
    
    // Create form data
    const formData = new FormData(form);
    
    // Submit with fetch
    fetch('settings_action.php', {
        method: 'POST',
        headers: {
            'X-Requested-With': 'XMLHttpRequest'
        },
        body: formData
    })
    .then(response => {
        // Check if response is ok
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        
        // Check if response is JSON
        const contentType = response.headers.get('content-type');
        if (!contentType || !contentType.includes('application/json')) {
            return response.text().then(text => {
                throw new Error(`Expected JSON but received: ${text}`);
            });
        }
        
        return response.json();
    })
    .then(data => {
        console.log('Response data:', data); // Debug log
        if (data.success) {
            showNotification(data.message, 'success');
        } else {
            showNotification(data.error || 'Có lỗi xảy ra', 'error');
        }
    })
    .catch(error => {
        console.error('Full error:', error);
        showNotification(`Lỗi: ${error.message}`, 'error');
    })
    .finally(() => {
        // Reset button state
        submitBtn.classList.remove('loading');
        submitBtn.disabled = false;
        submitBtn.innerHTML = originalText;
    });
}

function showNotification(message, type) {
    // Remove existing notifications
    const existingNotifications = document.querySelectorAll('.notification-popup');
    existingNotifications.forEach(notif => notif.remove());
    
    const notification = document.createElement('div');
    notification.className = `notification-popup ${type}`;
    
    const icon = type === 'success' ? '✅' : '❌';
    const iconClass = type === 'success' ? 'success-icon' : 'error-icon';
    
    notification.innerHTML = `
        <div class="notification-content">
            <div class="${iconClass}">${icon}</div>
            <div class="notification-message">${message}</div>
            <div class="notification-close" onclick="this.parentElement.parentElement.remove()">×</div>
        </div>
    `;
    
    document.body.appendChild(notification);
    
    // Show with animation
    setTimeout(() => notification.classList.add('show'), 100);
    
    // Auto remove after 5 seconds
    setTimeout(() => {
        if (notification.parentElement) {
            notification.classList.add('fade-out');
            setTimeout(() => notification.remove(), 400);
        }
    }, 5000);
}

// File upload drag and drop
document.querySelectorAll('.file-upload-area').forEach(area => {
    area.addEventListener('dragover', function(e) {
        e.preventDefault();
        this.style.borderColor = '#3b82f6';
        this.style.backgroundColor = '#eff6ff';
    });
    
    area.addEventListener('dragleave', function(e) {
        e.preventDefault();
        this.style.borderColor = '#d1d5db';
        this.style.backgroundColor = '#f9fafb';
    });
    
    area.addEventListener('drop', function(e) {
        e.preventDefault();
        this.style.borderColor = '#d1d5db';
        this.style.backgroundColor = '#f9fafb';
        
        const files = e.dataTransfer.files;
        if (files.length > 0) {
            const input = this.querySelector('input[type="file"]');
            input.files = files;
            input.dispatchEvent(new Event('change', { bubbles: true }));
        }
    });
});
</script>

<?php include '../includes/footer.php'; ?>
