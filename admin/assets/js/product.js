class ProductManager {
    constructor() {
        // Thêm sản phẩm - modal elements
        this.addModal = document.getElementById('addProductModal');
        this.addBtn = document.getElementById('addProductBtn');
        this.addForm = document.getElementById('addProductForm');
        this.addCloseBtn = this.addModal?.querySelector('.close');
        this.addCancelBtn = document.getElementById('cancelBtn');

        this.editModal = document.getElementById('editProductModal');
        this.editForm = document.getElementById('editProductForm');
        this.editCloseBtn = document.getElementById('editModalClose');
        this.editCancelBtn = document.getElementById('editCancelBtn');
        
        this.init();
    }


    init() {
        if (this.addBtn) {
            this.addBtn.addEventListener('click', () => this.showAddModal());
        }
        
        if (this.addCloseBtn) {
            this.addCloseBtn.addEventListener('click', () => this.hideAddModal());
        }
        
        if (this.addCancelBtn) {
            this.addCancelBtn.addEventListener('click', () => this.hideAddModal());
        }
        
        if (this.addForm) {
            this.addForm.addEventListener('submit', (e) => this.handleAddSubmit(e));
        }

        // Chỉnh sửa sản phẩm - modal event listeners
        if (this.editCloseBtn) {
            this.editCloseBtn.addEventListener('click', () => this.hideEditModal());
        }
        
        if (this.editCancelBtn) {
            this.editCancelBtn.addEventListener('click', () => this.hideEditModal());
        }
        
        if (this.editForm) {
            this.editForm.addEventListener('submit', (e) => this.handleEditSubmit(e));
        }

        window.addEventListener('click', (e) => {
            if (e.target === this.addModal) {
                this.hideAddModal();
            }
            if (e.target === this.editModal) {
                this.hideEditModal();
            }
        });

        document.addEventListener('keydown', (e) => {
            if (e.key === 'Escape') {
                if (this.addModal?.classList.contains('show')) {
                    this.hideAddModal();
                }
                if (this.editModal?.classList.contains('show')) {
                    this.hideEditModal();
                }
            }
        });
    }

    // Thêm sản phẩm
    showAddModal() {
        this.resetAddForm();
        this.addModal.classList.add('show');
        this.addModal.style.display = 'flex';
        document.body.style.overflow = 'hidden';
        
        const firstInput = this.addForm.querySelector('input[name="name"]');
        if (firstInput) {
            setTimeout(() => firstInput.focus(), 100);
        }
    }

    hideAddModal() {
        this.addModal.classList.remove('show');
        this.addModal.style.display = 'none';
        document.body.style.overflow = '';
        this.resetAddForm();
    }

    resetAddForm() {
        this.addForm.reset();
        this.clearErrors('errorMessages');
        this.setLoading(this.addForm, false);
    }

    async handleAddSubmit(e) {
        e.preventDefault();
        
        this.clearErrors('errorMessages');
        this.setLoading(this.addForm, true);

        const formData = new FormData(this.addForm);
        
        try {
            const response = await fetch('add_product.php', {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.showSuccess('errorMessages', result.message || 'Product added successfully');
                
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                this.showErrors('errorMessages', result.errors || ['An error occurred']);
            }
        } catch (error) {
            console.error('Error:', error);
            this.showErrors('errorMessages', ['Network error. Please try again.']);
        } finally {
            this.setLoading(this.addForm, false);
        }
    }

    // Chỉnh sửa sản phẩm
    async showEditModal(productId) {
        try {
            // Fetch product data
            const response = await fetch(`edit_product.php?id=${productId}`, {
                method: 'GET',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                }
            });

            const result = await response.json();

            if (result.success) {
                this.populateEditForm(result.data);
                this.editModal.classList.add('show');
                this.editModal.style.display = 'flex';
                document.body.style.overflow = 'hidden';
                
                const firstInput = this.editForm.querySelector('input[name="name"]');
                if (firstInput) {
                    setTimeout(() => firstInput.focus(), 100);
                }
            } else {
                alert(result.error || 'Error loading product data');
            }
        } catch (error) {
            console.error('Error:', error);
            alert('Network error. Please try again.');
        }
    }

    hideEditModal() {
        this.editModal.classList.remove('show');
        this.editModal.style.display = 'none';
        document.body.style.overflow = '';
        this.resetEditForm();
    }

    resetEditForm() {
        this.editForm.reset();
        this.clearErrors('editErrorMessages');
        this.setLoading(this.editForm, false);
    }

    populateEditForm(productData) {
        document.getElementById('editProductId').value = productData.id;
        document.getElementById('editProductName').value = productData.name || '';
        
        // Set selected category
        const categorySelect = document.getElementById('editProductCategory');
        if (categorySelect && productData.category) {
            categorySelect.value = productData.category;
        }
        
        document.getElementById('editProductPrice').value = productData.price || '';
        document.getElementById('editProductInventory').value = productData.inventory || '';
        document.getElementById('editProductDescription').value = productData.description || '';
        
        // Show current image preview
        const imagePreview = document.getElementById('currentImagePreview');
        if (productData.image && imagePreview) {
            imagePreview.innerHTML = `
                <div style="margin-top: 10px;">
                    <label style="display: block; margin-bottom: 5px; font-size: 12px; color: #666;">Current Image:</label>
                    <img src="../assets/images/uploads/${productData.image}" alt="Current product image" 
                         style="width: 100px; height: 100px; object-fit: cover; border: 1px solid #ddd; border-radius: 4px;">
                </div>
            `;
        } else if (imagePreview) {
            imagePreview.innerHTML = '<div style="margin-top: 10px; color: #999; font-size: 12px;">No current image</div>';
        }
        
        this.clearErrors('editErrorMessages');
    }

    async handleEditSubmit(e) {
        e.preventDefault();
        
        this.clearErrors('editErrorMessages');
        this.setLoading(this.editForm, true);

        const formData = new FormData(this.editForm);
        
        try {
            const response = await fetch('edit_product.php', {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.showSuccess('editErrorMessages', result.message || 'Product updated successfully');
                
                setTimeout(() => {
                    window.location.reload();
                }, 1000);
            } else {
                this.showErrors('editErrorMessages', result.errors || ['An error occurred']);
            }
        } catch (error) {
            console.error('Error:', error);
            this.showErrors('editErrorMessages', ['Network error. Please try again.']);
        } finally {
            this.setLoading(this.editForm, false);
        }
    }

    // Shared utility methods
    setLoading(form, isLoading) {
        const submitBtn = form.querySelector('button[type="submit"]');
        const btnText = submitBtn.querySelector('.btn-text');
        const spinner = submitBtn.querySelector('.loading-spinner');
        
        if (isLoading) {
            submitBtn.disabled = true;
            submitBtn.classList.add('loading');
            btnText.style.display = 'none';
            spinner.style.display = 'inline-block';
        } else {
            submitBtn.disabled = false;
            submitBtn.classList.remove('loading');
            btnText.style.display = 'inline-block';
            spinner.style.display = 'none';
        }
    }

    showErrors(containerId, errors) {
        const errorContainer = document.getElementById(containerId);
        errorContainer.innerHTML = '';
        
        errors.forEach(error => {
            const errorDiv = document.createElement('div');
            errorDiv.className = 'error';
            errorDiv.textContent = error;
            errorContainer.appendChild(errorDiv);
        });
    }

    showSuccess(containerId, message) {
        const errorContainer = document.getElementById(containerId);
        errorContainer.innerHTML = `<div class="success-message">${message}</div>`;
    }

    clearErrors(containerId) {
        const errorContainer = document.getElementById(containerId);
        if (errorContainer) {
            errorContainer.innerHTML = '';
        }
    }

    // Method to handle delete product with confirmation
    async deleteProduct(productId, productName) {
        // Create custom confirmation modal instead of browser confirm
        const confirmed = await this.showDeleteConfirmModal(productName);
        if (!confirmed) {
            return;
        }

        try {
            const formData = new FormData();
            formData.append('id', productId);

            const response = await fetch('delete_product.php', {
                method: 'POST',
                headers: {
                    'X-Requested-With': 'XMLHttpRequest'
                },
                body: formData
            });

            const result = await response.json();

            if (result.success) {
                this.showDeleteSuccessPopup(result.message);
                
                // Remove the row from table with animation
                setTimeout(() => {
                    window.location.reload();
                }, 2000);
            } else {
                this.showDeleteErrorPopup(result.error || 'Error deleting product');
            }
        } catch (error) {
            console.error('Error deleting product:', error);
            this.showDeleteErrorPopup('Network error. Please try again.');
        }
    }

    // xóa san phẩm - hiển thị modal xác nhận
    showDeleteConfirmModal(productName) {
        return new Promise((resolve) => {
            // Remove existing confirmation modal if any
            const existingModal = document.getElementById('deleteConfirmModal');
            if (existingModal) {
                existingModal.remove();
            }

            // Create confirmation modal
            const modal = document.createElement('div');
            modal.id = 'deleteConfirmModal';
            modal.className = 'modal show';
            modal.style.display = 'flex';
            
            modal.innerHTML = `
                <div class="modal-content" style="max-width: 400px;">
                    <div class="modal-header">
                        <h2>Confirm Delete</h2>
                    </div>
                    <div class="modal-body">
                        <p>Are you sure you want to delete <strong>"${productName}"</strong>?</p>
                        <p style="color: #666; font-size: 14px;">This action cannot be undone.</p>
                        <div class="form-actions" style="margin-top: 20px;">
                            <button type="button" class="btn btn-primary delete-confirm-btn" style="background-color: #dc3545; border-color: #dc3545;">
                                Delete
                            </button>
                            <button type="button" class="btn btn-secondary delete-cancel-btn">
                                Cancel
                            </button>
                        </div>
                    </div>
                </div>
            `;

            document.body.appendChild(modal);
            document.body.style.overflow = 'hidden';

            // Event listeners
            const confirmBtn = modal.querySelector('.delete-confirm-btn');
            const cancelBtn = modal.querySelector('.delete-cancel-btn');

            const cleanup = () => {
                document.body.style.overflow = '';
                modal.remove();
            };

            confirmBtn.addEventListener('click', () => {
                cleanup();
                resolve(true);
            });

            cancelBtn.addEventListener('click', () => {
                cleanup();
                resolve(false);
            });

            // Close on outside click
            modal.addEventListener('click', (e) => {
                if (e.target === modal) {
                    cleanup();
                    resolve(false);
                }
            });

            // Close on Escape key
            const escapeHandler = (e) => {
                if (e.key === 'Escape') {
                    document.removeEventListener('keydown', escapeHandler);
                    cleanup();
                    resolve(false);
                }
            };
            document.addEventListener('keydown', escapeHandler);
        });
    }

    // Show success popup after delete
    showDeleteSuccessPopup(message) {
        this.createNotificationPopup(message, 'success');
    }

    // Show error popup for delete
    showDeleteErrorPopup(message) {
        this.createNotificationPopup(message, 'error');
    }

    // Create notification popup
    createNotificationPopup(message, type) {
        // Remove existing popup if any
        const existingPopup = document.getElementById('deleteNotificationPopup');
        if (existingPopup) {
            existingPopup.remove();
        }

        // Create popup element
        const popup = document.createElement('div');
        popup.id = 'deleteNotificationPopup';
        popup.className = `notification-popup ${type}`;
        
        const icon = type === 'success' ? '✓' : '✗';
        const iconClass = type === 'success' ? 'success-icon' : 'error-icon';
        
        popup.innerHTML = `
            <div class="notification-content">
                <div class="${iconClass}">${icon}</div>
                <div class="notification-message">${message}</div>
                <div class="notification-close" onclick="this.parentElement.parentElement.remove()">×</div>
            </div>
        `;

        // Add to page
        document.body.appendChild(popup);

        // Show with animation
        setTimeout(() => {
            popup.classList.add('show');
        }, 10);

        // Auto remove after 3 seconds for success, 5 seconds for error
        setTimeout(() => {
            if (popup.parentElement) {
                popup.classList.add('fade-out');
                setTimeout(() => {
                    if (popup.parentElement) {
                        popup.remove();
                    }
                }, 300);
            }
        }, type === 'success' ? 3000 : 5000);
    }
}

// Initialize when DOM is loaded
let productManager;
document.addEventListener('DOMContentLoaded', function() {
    productManager = new ProductManager();
});

// Global functions for backwards compatibility
window.editProduct = function(productId, productName) {
    if (productManager) {
        productManager.showEditModal(productId);
    }
};

window.deleteProduct = function(productId, productName) {
    if (productManager) {
        productManager.deleteProduct(productId, productName);
    }
};
