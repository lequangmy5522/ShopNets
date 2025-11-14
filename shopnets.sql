-- Database: shopnets_db
-- Bảng người dùng
CREATE TABLE users (
    id INT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) UNIQUE NOT NULL,
    password VARCHAR(255) NOT NULL,
    email VARCHAR(100) UNIQUE NOT NULL,
    full_name VARCHAR(100) NOT NULL,
    address TEXT,
    phone VARCHAR(20),
    avatar VARCHAR(255) DEFAULT 'default_avatar.jpg',
    role ENUM('admin','customer') DEFAULT 'customer',
    email_verified BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    reset_token VARCHAR(255) DEFAULT NULL,
    reset_token_expires DATETIME DEFAULT NULL
);

-- Bảng danh mục sản phẩm
CREATE TABLE categories (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    description TEXT,
    image VARCHAR(255),
    parent_id INT DEFAULT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (parent_id) REFERENCES categories(id) ON DELETE SET NULL
);

-- Bảng thương hiệu
CREATE TABLE brands (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    slug VARCHAR(120) UNIQUE NOT NULL,
    description TEXT,
    logo VARCHAR(255),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng sản phẩm
CREATE TABLE products (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category_id INT,
    brand_id INT,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    description TEXT,
    short_description TEXT,
    sku VARCHAR(100) UNIQUE NOT NULL,
    price DECIMAL(12,2) NOT NULL,
    compare_price DECIMAL(12,2) DEFAULT NULL,
    flash_sale TINYINT(1) DEFAULT 0,
    cost_price DECIMAL(12,2) DEFAULT NULL,
    quantity INT DEFAULT 0,
    low_stock_threshold INT DEFAULT 5,
    weight DECIMAL(8,2) DEFAULT 0,
    dimensions VARCHAR(100),
    featured BOOLEAN DEFAULT FALSE,
    is_active BOOLEAN DEFAULT TRUE,
    meta_title VARCHAR(255),
    meta_description TEXT,
    meta_keywords TEXT,
    view_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE SET NULL,
    FOREIGN KEY (brand_id) REFERENCES brands(id) ON DELETE SET NULL
);

-- Bảng hình ảnh sản phẩm
CREATE TABLE product_images (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    image_path VARCHAR(255) NOT NULL,
    alt_text VARCHAR(255),
    sort_order INT DEFAULT 0,
    is_primary BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Bảng thuộc tính sản phẩm
CREATE TABLE attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    type ENUM('text','select','color','size') DEFAULT 'text',
    is_filterable BOOLEAN DEFAULT FALSE,
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng giá trị thuộc tính
CREATE TABLE attribute_values (
    id INT AUTO_INCREMENT PRIMARY KEY,
    attribute_id INT NOT NULL,
    value VARCHAR(255) NOT NULL,
    color_code VARCHAR(7),
    sort_order INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE
);

-- Bảng thuộc tính sản phẩm
CREATE TABLE product_attributes (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    attribute_id INT NOT NULL,
    attribute_value_id INT,
    value_text TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_id) REFERENCES attributes(id) ON DELETE CASCADE,
    FOREIGN KEY (attribute_value_id) REFERENCES attribute_values(id) ON DELETE CASCADE
);

-- Bảng đánh giá sản phẩm
CREATE TABLE reviews (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT NOT NULL,
    rating TINYINT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    title VARCHAR(255),
    comment TEXT,
    is_approved BOOLEAN DEFAULT FALSE,
    helpful_count INT DEFAULT 0,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Bảng đơn hàng
CREATE TABLE orders (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_number VARCHAR(50) UNIQUE NOT NULL,
    user_id INT,
    customer_email VARCHAR(100) NOT NULL,
    customer_name VARCHAR(100) NOT NULL,
    customer_phone VARCHAR(20),
    shipping_address TEXT NOT NULL,
    billing_address TEXT,
    subtotal DECIMAL(12,2) NOT NULL,
    shipping_fee DECIMAL(10,2) DEFAULT 0,
    tax_amount DECIMAL(10,2) DEFAULT 0,
    discount_amount DECIMAL(10,2) DEFAULT 0,
    total_amount DECIMAL(12,2) NOT NULL,
    payment_method ENUM('cod','bank_transfer','momo','vnpay') DEFAULT 'cod',
    payment_status ENUM('pending','paid','failed','refunded') DEFAULT 'pending',
    order_status ENUM('pending','confirmed','processing','shipped','delivered','cancelled') DEFAULT 'pending',
    shipping_method VARCHAR(100),
    tracking_number VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Bảng chi tiết đơn hàng
CREATE TABLE order_items (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    product_id INT NOT NULL,
    product_name VARCHAR(255) NOT NULL,
    product_price DECIMAL(10,2) NOT NULL,
    quantity INT NOT NULL,
    total_price DECIMAL(10,2) NOT NULL,
    attributes JSON,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Bảng mã giảm giá
CREATE TABLE coupons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    code VARCHAR(50) UNIQUE NOT NULL,
    description TEXT,
    discount_type ENUM('percentage','fixed') DEFAULT 'percentage',
    discount_value DECIMAL(10,2) NOT NULL,
    minimum_order DECIMAL(10,2) DEFAULT 0,
    maximum_discount DECIMAL(10,2) DEFAULT NULL,
    usage_limit INT DEFAULT NULL,
    used_count INT DEFAULT 0,
    valid_from TIMESTAMP NULL,
    valid_until TIMESTAMP NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng lịch sử sử dụng coupon
CREATE TABLE coupon_usage (
    id INT AUTO_INCREMENT PRIMARY KEY,
    coupon_id INT NOT NULL,
    user_id INT NOT NULL,
    order_id INT NOT NULL,
    discount_amount DECIMAL(10,2) NOT NULL,
    used_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (coupon_id) REFERENCES coupons(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Bảng yêu thích sản phẩm
CREATE TABLE wishlists (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    UNIQUE KEY unique_wishlist (user_id, product_id)
);

-- Bảng so sánh sản phẩm
CREATE TABLE product_comparisons (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    session_id VARCHAR(100),
    product_id INT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Bảng lịch sử xem sản phẩm
CREATE TABLE product_views (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    user_id INT,
    session_id VARCHAR(100),
    ip_address VARCHAR(45),
    user_agent TEXT,
    viewed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE SET NULL
);

-- Bảng tồn kho
CREATE TABLE inventory (
    id INT AUTO_INCREMENT PRIMARY KEY,
    product_id INT NOT NULL,
    quantity INT NOT NULL,
    type ENUM('in','out','adjustment') NOT NULL,
    reason VARCHAR(255),
    reference_id INT DEFAULT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (product_id) REFERENCES products(id) ON DELETE CASCADE
);

-- Bảng bài viết/blog
CREATE TABLE posts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    slug VARCHAR(255) UNIQUE NOT NULL,
    excerpt TEXT,
    content LONGTEXT,
    featured_image VARCHAR(255),
    author_id INT NOT NULL,
    status ENUM('draft','published','archived') DEFAULT 'draft',
    is_featured BOOLEAN DEFAULT FALSE,
    view_count INT DEFAULT 0,
    meta_title VARCHAR(255),
    meta_description TEXT,
    published_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    FOREIGN KEY (author_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Bảng liên hệ
CREATE TABLE contacts (
    id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL,
    email VARCHAR(100) NOT NULL,
    phone VARCHAR(20),
    subject VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    status ENUM('new','read','replied','closed') DEFAULT 'new',
    ip_address VARCHAR(45),
    user_agent TEXT,
    replied_at TIMESTAMP NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng lịch sử trạng thái đơn hàng
CREATE TABLE order_status_history (
    id INT AUTO_INCREMENT PRIMARY KEY,
    order_id INT NOT NULL,
    status ENUM('pending','confirmed','processing','shipped','delivered','cancelled') NOT NULL,
    note TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
);

-- Bảng admin (từ database shopnets)
CREATE TABLE admin (
    id INT AUTO_INCREMENT PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20) DEFAULT NULL,
    avatar VARCHAR(255) DEFAULT NULL,
    password VARCHAR(255) NOT NULL,
    role ENUM('admin','user') DEFAULT 'user',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng settings (từ database shopnets)
CREATE TABLE settings (
    id INT AUTO_INCREMENT PRIMARY KEY,
    category VARCHAR(50) NOT NULL,
    setting_key VARCHAR(100) NOT NULL,
    setting_value TEXT DEFAULT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE KEY unique_setting (category, setting_key)
);

-- Chèn dữ liệu mẫu cho các đơn hàng hiện có
INSERT INTO order_status_history (order_id, status, created_at)
SELECT id, order_status, created_at FROM orders 
WHERE NOT EXISTS (SELECT 1 FROM order_status_history WHERE order_status_history.order_id = orders.id);

-- Tạo indexes để tối ưu hiệu suất
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_products_brand ON products(brand_id);
CREATE INDEX idx_products_featured ON products(featured);
CREATE INDEX idx_products_active ON products(is_active);
CREATE INDEX idx_orders_user ON orders(user_id);
CREATE INDEX idx_orders_status ON orders(order_status);
CREATE INDEX idx_order_items_order ON order_items(order_id);
CREATE INDEX idx_reviews_product ON reviews(product_id);
CREATE INDEX idx_reviews_user ON reviews(user_id);
CREATE INDEX idx_wishlists_user ON wishlists(user_id);

-- Tạo trigger để tự động cập nhật updated_at
DELIMITER //
CREATE TRIGGER update_products_updated_at
BEFORE UPDATE ON products
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
DELIMITER ;

DELIMITER //
CREATE TRIGGER update_users_updated_at
BEFORE UPDATE ON users
FOR EACH ROW
BEGIN
    SET NEW.updated_at = CURRENT_TIMESTAMP;
END//
DELIMITER ;

-- Tạo view để thống kê sản phẩm
CREATE VIEW product_stats AS
SELECT 
    p.id,
    p.name,
    p.sku,
    p.price,
    p.quantity,
    COALESCE(SUM(oi.quantity), 0) as total_sold,
    COALESCE(AVG(r.rating), 0) as avg_rating,
    COUNT(r.id) as review_count
FROM products p
LEFT JOIN order_items oi ON p.id = oi.product_id
LEFT JOIN reviews r ON p.id = r.product_id AND r.is_approved = TRUE
GROUP BY p.id, p.name, p.sku, p.price, p.quantity;

-- Tạo stored procedure để lấy sản phẩm theo danh mục
DELIMITER //
CREATE PROCEDURE GetProductsByCategory(IN category_id INT)
BEGIN
    SELECT 
        p.*,
        c.name as category_name,
        b.name as brand_name,
        (SELECT image_path FROM product_images WHERE product_id = p.id AND is_primary = TRUE LIMIT 1) as primary_image
    FROM products p
    LEFT JOIN categories c ON p.category_id = c.id
    LEFT JOIN brands b ON p.brand_id = b.id
    WHERE p.category_id = category_id AND p.is_active = TRUE
    ORDER BY p.featured DESC, p.created_at DESC;
END//
DELIMITER ;

-- Tạo function để tính doanh thu theo tháng
DELIMITER //
CREATE FUNCTION GetMonthlyRevenue(month INT, year INT)
RETURNS DECIMAL(12,2)
READS SQL DATA
DETERMINISTIC
BEGIN
    DECLARE revenue DECIMAL(12,2);
    SELECT COALESCE(SUM(total_amount), 0) INTO revenue
    FROM orders 
    WHERE MONTH(created_at) = month AND YEAR(created_at) = year 
    AND order_status = 'delivered';
    RETURN revenue;
END//
DELIMITER ;

UPDATE products SET flash_sale = 1 WHERE id IN (1, 5, 9, 13, 17, 21, 25, 29);

-- Thêm dữ liệu mẫu cho brands
INSERT INTO brands (name, slug, description) VALUES
('Samsung', 'samsung', 'Samsung Electronics'),
('Apple', 'apple', 'Apple Inc.'),
('Google', 'google', 'Google LLC'),
('Dell', 'dell', 'Dell Technologies'),
('Lenovo', 'lenovo', 'Lenovo Group'),
('Anker', 'anker', 'Anker Innovations'),
('Belkin', 'belkin', 'Belkin International'),
('Garmin', 'garmin', 'Garmin Ltd.'),
('Sony', 'sony', 'Sony Corporation'),
('Bose', 'bose', 'Bose Corporation');

-- Thêm dữ liệu mẫu cho categories
INSERT INTO categories (name, slug, description, parent_id, sort_order) VALUES
('Điện thoại', 'dien-thoai', 'Smartphone các loại', NULL, 1),
('Laptop', 'laptop', 'Máy tính xách tay', NULL, 2),
('Máy tính bảng', 'may-tinh-bang', 'Tablet các hãng', NULL, 3),
('Phụ kiện', 'phu-kien', 'Phụ kiện công nghệ', NULL, 4),
('Đồng hồ thông minh', 'dong-ho-thong-minh', 'Smartwatch', NULL, 5),
('Tai nghe', 'tai-nghe', 'Headphone & Earbuds', NULL, 6);


-- Thêm dữ liệu mẫu cho admin (từ database shopnets)
INSERT INTO admin (id, email, phone, avatar, password, role, created_at) VALUES
(1, 'admin@shopnet.com', '0984831424', 'assets/images/uploads/avatar_1762624304_690f83309e991.jpg', '$2y$10$M5VccEUAL6xamNY.YL5kzOYwLl.D6TfQnHfJNPqst33hkONPkMzPe', 'admin', '2025-11-01 08:27:30');

-- Thêm dữ liệu mẫu cho settings (từ database shopnets)
INSERT INTO settings (id, category, setting_key, setting_value, created_at, updated_at) VALUES
(1, 'website_info', 'site_name', 'ShopNets', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(2, 'website_info', 'site_tagline', 'Your Online Shopping Destination', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(3, 'website_info', 'meta_description', 'ShopNets - Nền tảng mua sắm trực tuyến hàng đầu với hàng ngàn sản phẩm chất lượng cao và dịch vụ tốt nhất.', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(4, 'website_info', 'site_keywords', 'mua sắm, online shopping, thời trang, điện tử', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(5, 'contact_info', 'contact_email', 'admin@shopnets.com', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(6, 'contact_info', 'support_email', 'support@shopnets.com', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(7, 'contact_info', 'contact_phone', '0123-456-789', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(8, 'contact_info', 'contact_hotline', '1900-1234', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(9, 'contact_info', 'contact_address', '123 Đường ABC, Phường XYZ, Quận 1, TP. Hồ Chí Minh, Việt Nam', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(10, 'contact_info', 'working_hours', '8:00 - 17:00, Thứ 2 - Chủ nhật', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(11, 'contact_info', 'website', 'https://shopnets.com', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(12, 'system_settings', 'currency', 'VND', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(13, 'system_settings', 'timezone', 'Asia/Ho_Chi_Minh', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(14, 'system_settings', 'language', 'vi', '2025-11-08 17:13:08', '2025-11-08 17:13:08'),
(15, 'system_settings', 'date_format', 'd/m/Y', '2025-11-08 17:13:08', '2025-11-08 17:13:08');


-- 1. ĐIỆN THOẠI (Apple, Samsung, Google - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(1, 2, 'iPhone 16 Pro Max', 'iphone-16-pro-max', 'Chip A18 Pro, Apple Intelligence', 'IP16-PRO-MAX', 34990000, 37990000, 40, TRUE, TRUE),
(1, 2, 'iPhone 17', 'iphone-17', 'Màn hình 6.1", A18', 'IP16', 24990000, 27990000, 50, TRUE, TRUE),
(1, 2, 'iPhone Air', 'iphone-air', 'Mỏng nhẹ, chip A19 Pro', 'IP-AIR', 31990000, 34990000, 30, TRUE, TRUE),
(1, 2, 'iPhone SE 4', 'iphone-se-4', 'Giá rẻ, chip A17', 'IP-SE4', 13990000, 15990000, 60, FALSE, TRUE),
(1, 1, 'Samsung Galaxy S25 Ultra', 'samsung-galaxy-s25-ultra', 'Camera 200MP, AI mạnh mẽ', 'S25-ULTRA', 29990000, 32990000, 50, TRUE, TRUE),
(1, 1, 'Samsung Galaxy Z Fold 7', 'samsung-galaxy-z-fold-7', 'Màn hình gập 8 inch', 'ZFOLD7', 45990000, 49990000, 20, TRUE, TRUE),
(1, 1, 'Samsung Galaxy S25', 'samsung-galaxy-s25', 'Snapdragon 8 Gen 4', 'S25', 22990000, 25990000, 55, FALSE, TRUE),
(1, 1, 'Samsung Galaxy A56', 'samsung-galaxy-a56', 'Tầm trung, camera 50MP', 'A56', 10990000, 12990000, 70, FALSE, TRUE),
(1, 3, 'Google Pixel 10 Pro XL', 'google-pixel-10-pro-xl', 'Camera AI, cập nhật 7 năm', 'PIXEL10-PRO-XL', 27990000, 30990000, 35, TRUE, TRUE),
(1, 3, 'Google Pixel 10', 'google-pixel-10', 'Tensor G4, thiết kế mới', 'PIXEL10', 19990000, 22990000, 45, FALSE, TRUE),
(1, 3, 'Google Pixel 9a', 'google-pixel-9a', 'Camera AI, giá phải chăng', 'PIXEL9A', 12990000, 14990000, 80, FALSE, TRUE),
(1, 3, 'Google Pixel Fold 2', 'google-pixel-fold-2', 'Màn hình gập, Tensor G4', 'PIXEL-FOLD2', 39990000, 42990000, 25, TRUE, TRUE);

-- 2. LAPTOP (Apple, Dell, Lenovo - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(2, 2, 'MacBook Air M4 (2025)', 'macbook-air-m4-2025', 'Chip M4, pin 18 giờ', 'MBA-M4', 28990000, 31990000, 45, TRUE, TRUE),
(2, 2, 'MacBook Pro M4 14"', 'macbook-pro-m4-14', 'Chip M4 Pro, màn Retina', 'MBP-M4-14', 39990000, 42990000, 30, TRUE, TRUE),
(2, 2, 'MacBook Pro M4 Max 16"', 'macbook-pro-m4-max-16', 'Hiệu năng đỉnh cao', 'MBP-M4-MAX', 59990000, 64990000, 20, TRUE, TRUE),
(2, 2, 'MacBook Air M3', 'macbook-air-m3', 'Chip M3, giá tốt', 'MBA-M3', 24990000, 27990000, 50, FALSE, TRUE),
(2, 4, 'Dell XPS 13 (2025)', 'dell-xps-13-2025', 'Thiết kế mỏng, Intel Core Ultra', 'XPS13-2025', 33990000, 36990000, 30, TRUE, TRUE),
(2, 4, 'Dell Inspiron 16', 'dell-inspiron-16', 'Màn 16", RTX 3050', 'INSPIRON-16', 22990000, 25990000, 40, FALSE, TRUE),
(2, 4, 'Dell Latitude 7450', 'dell-latitude-7450', 'Doanh nhân, pin dài', 'LATITUDE-7450', 29990000, 32990000, 35, FALSE, TRUE),
(2, 4, 'Dell Alienware M16', 'dell-alienware-m16', 'Gaming, RTX 4070', 'ALIEN-M16', 49990000, 52990000, 25, TRUE, TRUE),
(2, 5, 'Lenovo Yoga 9i Gen 10', 'lenovo-yoga-9i-gen10', '2-in-1, màn OLED 14"', 'YOGA9I-G10', 35990000, 38990000, 25, TRUE, TRUE),
(2, 5, 'Lenovo ThinkPad X1 Carbon', 'lenovo-thinkpad-x1-carbon', 'Doanh nhân, bền bỉ', 'THINKPAD-X1', 36990000, 39990000, 20, TRUE, TRUE),
(2, 5, 'Lenovo Legion 7i', 'lenovo-legion-7i', 'Gaming, RTX 4060', 'LEGION-7I', 39990000, 42990000, 30, TRUE, TRUE),
(2, 5, 'Lenovo IdeaPad Slim 5', 'lenovo-ideapad-slim5', 'Tầm trung, OLED', 'IDEAPAD-SLIM5', 18990000, 20990000, 50, FALSE, TRUE);

-- 3. MÁY TÍNH BẢNG (Apple, Samsung, Lenovo - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(3, 2, 'iPad (11th Gen, 2025)', 'ipad-11gen-2025', 'Chip A16, giá tốt', 'IPAD-11GEN', 12990000, 14990000, 60, TRUE, TRUE),
(3, 2, 'iPad Air (7th Gen)', 'ipad-air-7gen', 'Chip M3, 13"', 'IPAD-AIR7', 18990000, 20990000, 40, TRUE, TRUE),
(3, 2, 'iPad Pro M4 11"', 'ipad-pro-m4-11', 'Màn OLED, Apple Pencil Pro', 'IPAD-PRO-M4-11', 28990000, 31990000, 30, TRUE, TRUE),
(3, 2, 'iPad Mini 7', 'ipad-mini-7', '8.3", chip A17 Pro', 'IPAD-MINI7', 15990000, 17990000, 50, FALSE, TRUE),
(3, 1, 'Samsung Galaxy Tab S11 Ultra', 'samsung-galaxy-tab-s11-ultra', '14.6" AMOLED, S Pen', 'TABS11-ULTRA', 28990000, 31990000, 25, TRUE, TRUE),
(3, 1, 'Samsung Galaxy Tab S10 Plus', 'samsung-galaxy-tab-s10-plus', '12.4", IP68', 'TABS10-PLUS', 22990000, 25990000, 35, TRUE, TRUE),
(3, 1, 'Samsung Galaxy Tab S9 FE', 'samsung-galaxy-tab-s9-fe', 'S Pen, giá tốt', 'TABS9-FE', 10990000, 12990000, 70, FALSE, TRUE),
(3, 1, 'Samsung Galaxy Tab A9+', 'samsung-galaxy-tab-a9-plus', 'Giá rẻ, 11"', 'TABA9-PLUS', 6990000, 8990000, 80, FALSE, TRUE),
(3, 5, 'Lenovo Legion Tab Gen 3', 'lenovo-legion-tab-gen3', 'Gaming, 144Hz', 'LEGION-TAB3', 15990000, 17990000, 30, TRUE, TRUE),
(3, 5, 'Lenovo Tab P12', 'lenovo-tab-p12', '12.7", pin lớn', 'TAB-P12', 9990000, 11990000, 50, FALSE, TRUE),
(3, 5, 'Lenovo Tab M11', 'lenovo-tab-m11', 'Giá rẻ, bút stylus', 'TAB-M11', 5990000, 7990000, 70, FALSE, TRUE),
(3, 5, 'Lenovo Yoga Tab 13', 'lenovo-yoga-tab-13', 'Màn 2K, chân đế', 'YOGA-TAB13', 14990000, 16990000, 40, TRUE, TRUE);

-- 4. PHỤ KIỆN (Anker, Belkin, Apple - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(4, 6, 'Anker MagSafe Power Bank 10K', 'anker-magsafe-powerbank-10k', 'Sạc không dây, kickstand', 'ANKER-MAG10K', 1499000, 1799000, 100, TRUE, TRUE),
(4, 6, 'Anker Bio-Braided USB-C 240W', 'anker-bio-cable-240w', 'Sạc nhanh, thân thiện môi trường', 'ANKER-BIO240W', 399000, 599000, 120, FALSE, TRUE),
(4, 6, 'Anker Soundcore Speaker', 'anker-soundcore-speaker', 'Loa Bluetooth, chống nước', 'ANKER-SPEAKER', 1299000, 1599000, 90, TRUE, TRUE),
(4, 6, 'Anker USB-C Hub 8-in-1', 'anker-usb-c-hub-8in1', 'Kết nối đa năng', 'ANKER-HUB8', 1999000, 2299000, 80, FALSE, TRUE),
(4, 7, 'Belkin PowerGrip', 'belkin-powergrip', 'Sạc 3-in-1, cầm tay', 'BELKIN-GRIP', 1899000, 2199000, 80, FALSE, TRUE),
(4, 7, 'Belkin BoostCharge Pro', 'belkin-boostcharge-pro', 'Sạc nhanh 65W', 'BELKIN-CHARGE', 999000, 1299000, 100, TRUE, TRUE),
(4, 7, 'Belkin MagSafe Car Mount', 'belkin-magsafe-car-mount', 'Giá đỡ xe hơi', 'BELKIN-CARMOUNT', 799000, 999000, 110, FALSE, TRUE),
(4, 7, 'Belkin USB-C Cable 2m', 'belkin-usb-c-cable', 'Sạc nhanh, bền bỉ', 'BELKIN-CABLE', 499000, 699000, 120, FALSE, TRUE),
(4, 2, 'Apple AirTag (4-pack)', 'apple-airtag-4pack', 'Theo dõi đồ vật', 'AIRTAG-4PACK', 2599000, 2999000, 100, TRUE, TRUE),
(4, 2, 'Apple MagSafe Charger', 'apple-magsafe-charger', 'Sạc không dây nhanh', 'APPLE-MAGSAFE', 1199000, 1399000, 90, TRUE, TRUE),
(4, 2, 'Apple USB-C to Lightning', 'apple-usb-c-lightning', 'Cáp chính hãng', 'APPLE-CABLE', 599000, 799000, 110, FALSE, TRUE),
(4, 2, 'Apple Magic Keyboard', 'apple-magic-keyboard', 'Bàn phím iPad', 'APPLE-KEYBOARD', 2999000, 3299000, 50, TRUE, TRUE);

-- 5. ĐỒNG HỒ THÔNG MINH (Apple, Samsung, Garmin - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(5, 2, 'Apple Watch Series 11', 'apple-watch-series11', 'Màn hình lớn, AI sức khỏe', 'WATCH-S11', 11990000, 13990000, 60, TRUE, TRUE),
(5, 2, 'Apple Watch Ultra 3', 'apple-watch-ultra3', 'Chống nước sâu, phiêu lưu', 'WATCH-ULTRA3', 21990000, 23990000, 25, TRUE, TRUE),
(5, 2, 'Apple Watch SE 3', 'apple-watch-se3', 'Giá rẻ, theo dõi sức khỏe', 'WATCH-SE3', 6990000, 8990000, 70, FALSE, TRUE),
(5, 2, 'Apple Watch Series 10', 'apple-watch-series10', 'Cảm biến giấc ngủ', 'WATCH-S10', 9990000, 11990000, 50, TRUE, TRUE),
(5, 1, 'Samsung Galaxy Watch 8', 'samsung-galaxy-watch8', 'Theo dõi giấc ngủ apnea', 'WATCH8', 8990000, 10990000, 70, TRUE, TRUE),
(5, 1, 'Samsung Galaxy Watch Ultra 2025', 'samsung-galaxy-watch-ultra-2025', 'Thiết kế rugged', 'WATCH-ULTRA2025', 14990000, 16990000, 35, TRUE, TRUE),
(5, 1, 'Samsung Galaxy Watch 7', 'samsung-galaxy-watch7', 'Pin 48 giờ, AI', 'WATCH7', 7990000, 9990000, 80, FALSE, TRUE),
(5, 1, 'Samsung Galaxy Watch FE', 'samsung-galaxy-watch-fe', 'Giá rẻ, tính năng cơ bản', 'WATCH-FE', 4990000, 6990000, 100, FALSE, TRUE),
(5, 8, 'Garmin Venu 4', 'garmin-venu4', 'Fitness chuyên sâu, pin 14 ngày', 'VENU4', 10990000, 12990000, 40, TRUE, TRUE),
(5, 8, 'Garmin Instinct 3', 'garmin-instinct3', 'Chống sốc, lặn sâu', 'INSTINCT3', 12990000, 14990000, 30, TRUE, TRUE),
(5, 8, 'Garmin Forerunner 965', 'garmin-forerunner-965', 'Chạy bộ, GPS chính xác', 'FORERUNNER-965', 14990000, 16990000, 35, TRUE, TRUE),
(5, 8, 'Garmin Venu Sq 2', 'garmin-venu-sq2', 'Giá rẻ, pin 11 ngày', 'VENU-SQ2', 6990000, 8990000, 60, FALSE, TRUE);

-- 6. TAI NGHE (Sony, Bose, Apple - 12 sản phẩm)
INSERT INTO products (category_id, brand_id, name, slug, short_description, sku, price, compare_price, quantity, featured, is_active) VALUES
(6, 9, 'Sony WH-1000XM6', 'sony-wh-1000xm6', 'ANC đỉnh cao, pin 30 giờ', 'WH-1000XM6', 8990000, 9990000, 50, TRUE, TRUE),
(6, 9, 'Sony WF-1000XM5', 'sony-wf-1000xm5', 'True wireless, ANC xuất sắc', 'WF-1000XM5', 6990000, 7990000, 60, TRUE, TRUE),
(6, 9, 'Sony LinkBuds S', 'sony-linkbuds-s', 'Nhỏ gọn, âm thanh trong', 'LINKBUDS-S', 3990000, 4990000, 80, FALSE, TRUE),
(6, 9, 'Sony WH-CH720N', 'sony-wh-ch720n', 'ANC giá rẻ, pin 35 giờ', 'WH-CH720N', 2990000, 3990000, 100, FALSE, TRUE),
(6, 10, 'Bose QuietComfort Ultra', 'bose-quietcomfort-ultra', 'ANC tốt nhất, bass mạnh', 'QC-ULTRA', 9490000, 10990000, 45, TRUE, TRUE),
(6, 10, 'Bose QuietComfort Earbuds', 'bose-qc-earbuds', 'True wireless, ANC mạnh', 'QC-EARBUDS', 6490000, 7490000, 60, TRUE, TRUE),
(6, 10, 'Bose SoundLink Max', 'bose-soundlink-max', 'Loa Bluetooth, pin 20 giờ', 'SOUNDLINK-MAX', 7990000, 8990000, 50, TRUE, TRUE),
(6, 10, 'Bose QuietComfort 45', 'bose-qc45', 'ANC cổ điển, pin 24 giờ', 'QC45', 6990000, 7990000, 70, FALSE, TRUE),
(6, 2, 'Apple AirPods Pro 2', 'apple-airpods-pro2', 'ANC thích ứng, sạc không dây', 'AIRPODS-PRO2', 6490000, 7490000, 80, TRUE, TRUE),
(6, 2, 'Apple AirPods 4', 'apple-airpods-4', 'Âm thanh không gian', 'AIRPODS-4', 3990000, 4990000, 90, FALSE, TRUE),
(6, 2, 'Apple AirPods Max', 'apple-airpods-max', 'Over-ear, ANC cao cấp', 'AIRPODS-MAX', 12990000, 14990000, 30, TRUE, TRUE),
(6, 2, 'Apple Beats Solo 4', 'apple-beats-solo4', 'Âm thanh mạnh, pin 50 giờ', 'BEATS-SOLO4', 4990000, 5990000, 60, FALSE, TRUE);

-- Ảnh cho các sản phẩm mới (72 sản phẩm)
INSERT INTO product_images (product_id, image_path, alt_text, is_primary, sort_order) VALUES
(1, 'products/phones/iphone_16_pro_max.jpg', 'iPhone 16 Pro Max', TRUE, 1),
(2, 'products/phones/iphone_17_pro_max.jpg', 'iPhone 17', TRUE, 1),
(3, 'products/phones/iphone_air.webp', 'iPhone Air', TRUE, 1),
(4, 'products/phones/iphone_se_4.jpg', 'iPhone SE 4', TRUE, 1),
(5, 'products/phones/galaxy_s25_ultra.jpg', 'Samsung Galaxy S25 Ultra', TRUE, 1),
(6, 'products/phones/Samsung_Galaxy_Z_Fold_7.webp', 'Samsung Galaxy Z Fold 7', TRUE, 1),
(7, 'products/phones/galaxy_s25.jpg', 'Samsung Galaxy S25', TRUE, 1),
(8, 'products/phones/galaxy_a56.jpg', 'Samsung Galaxy A56', TRUE, 1),
(9, 'products/phones/google_pixel_10_pro_xl.png', 'Google Pixel 10 Pro XL', TRUE, 1),
(10, 'products/phones/google_pixel_10.jpg', 'Google Pixel 10', TRUE, 1),
(11, 'products/phones/google_pixel_9a.jpg', 'Google Pixel 9a', TRUE, 1),
(12, 'products/phones/google_pixel_fold.jpg', 'Google Pixel Fold 2', TRUE, 1),
(13, 'products/latops/macbook_air_m4.jpg', 'MacBook Air M4', TRUE, 1),
(14, 'products/latops/macboo_pro_m4.webp', 'MacBook Pro M4 14"', TRUE, 1),
(15, 'products/latops/macbook_pro_m4_16.jpg', 'MacBook Pro M4 Max 16"', TRUE, 1),
(16, 'products/latops/macbook_air_13.jpg', 'MacBook Air M3', TRUE, 1),
(17, 'products/latops/dell_xps_13.jpg', 'Dell XPS 13 2025', TRUE, 1),
(18, 'products/latops/dell_inspiron_16.webp', 'Dell Inspiron 16', TRUE, 1),
(19, 'products/latops/Dell-Latitude-7450.jpg', 'Dell Latitude 7450', TRUE, 1),
(20, 'products/latops/dell_alienware_m16.jpg', 'Dell Alienware M16', TRUE, 1),
(21, 'products/latops/lenovo_yoga_9l.jpg', 'Lenovo Yoga 9i', TRUE, 1),
(22, 'products/latops/lenovo-thinkpad-x1-carbon-gen11.jpg', 'Lenovo ThinkPad X1 Carbon', TRUE, 1),
(23, 'products/latops/lenovo_legion_7l.avif', 'Lenovo Legion 7i', TRUE, 1),
(24, 'products/latops/lenovo_ideapad_slim5.jpg', 'Lenovo IdeaPad Slim 5', TRUE, 1),
(25, 'products/tablets/ipad-11gen-2025.webp', 'iPad 11th Gen', TRUE, 1),
(26, 'products/tablets/ipad-air-7gen.png', 'iPad Air 7th Gen', TRUE, 1),
(27, 'products/tablets/ipad-pro-m4-11.jpg', 'iPad Pro M4 11"', TRUE, 1),
(28, 'products/tablets/ipad-mini-7.jpg', 'iPad Mini 7', TRUE, 1),
(29, 'products/tablets/samsung-galaxy-tab-s11-ultra.webp', 'Samsung Galaxy Tab S11 Ultra', TRUE, 1),
(30, 'products/tablets/samsung-galaxy-tab-s10-plus.jpg', 'Samsung Galaxy Tab S10 Plus', TRUE, 1),
(31, 'products/tablets/samsung-galaxy-tab-s9-fe.webp', 'Samsung Galaxy Tab S9 FE', TRUE, 1),
(32, 'products/tablets/samsung-galaxy-tab-a9-plus.avif', 'Samsung Galaxy Tab A9+', TRUE, 1),
(33, 'products/tablets/lenovo-legion-tab-gen3.jpg', 'Lenovo Legion Tab Gen 3', TRUE, 1),
(34, 'products/tablets/lenovo-tab-p12.jpg', 'Lenovo Tab P12', TRUE, 1),
(35, 'products/tablets/lenovo-tab-m11.jpg', 'Lenovo Tab M11', TRUE, 1),
(36, 'products/tablets/lenovo-yoga-tab-13.jpg', 'Lenovo Yoga Tab 13', TRUE, 1),
(37, 'products/accessories/Anker-MagSafe-Power-Bank-10K.webp', 'Anker MagSafe Power Bank', TRUE, 1),
(38, 'products/accessories/Anker-Bio-Braided-USB-C-240W.jpg', 'Anker Bio-Braided Cable', TRUE, 1),
(39, 'products/accessories/Anker -Soundcore-Speaker.jpg', 'Anker Soundcore Speaker', TRUE, 1),
(40, 'products/accessories/Anker-USB-C-Hub 8-in-1.jpg', 'Anker USB-C Hub 8-in-1', TRUE, 1),
(41, 'products/accessories/belkin-powergrip.webp', 'Belkin PowerGrip', TRUE, 1),
(42, 'products/accessories/belkin-boostcharge-pro.jpg', 'Belkin BoostCharge Pro', TRUE, 1),
(43, 'products/accessories/belkin-magsafe-car-mount.avif', 'Belkin MagSafe Car Mount', TRUE, 1),
(44, 'products/accessories/belkin-usb-c-cable.jpg', 'Belkin USB-C Cable', TRUE, 1),
(45, 'products/accessories/apple-airtag-4pack.jpeg', 'Apple AirTag', TRUE, 1),
(46, 'products/accessories/apple-magsafe-charger.webp', 'Apple MagSafe Charger', TRUE, 1),
(47, 'products/accessories/apple-usb-c-lightning.jpg', 'Apple USB-C to Lightning', TRUE, 1),
(48, 'products/accessories/apple-magic-keyboard.jpg', 'Apple Magic Keyboard', TRUE, 1),
(49, 'products/smartwatches/apple-watch-series11.webp', 'Apple Watch Series 11', TRUE, 1),
(50, 'products/smartwatches/apple-watch-ultra3.webp', 'Apple Watch Ultra 3', TRUE, 1),
(51, 'products/smartwatches/apple-watch-se3.avif', 'Apple Watch SE 3', TRUE, 1),
(52, 'products/smartwatches/apple-watch-series10.jpg', 'Apple Watch Series 10', TRUE, 1),
(53, 'products/smartwatches/samsung-galaxy-watch8.webp', 'Samsung Galaxy Watch 8', TRUE, 1),
(54, 'products/smartwatches/samsung-galaxy-watch-ultra-2025.jpg', 'Samsung Galaxy Watch Ultra 2025', TRUE, 1),
(55, 'products/smartwatches/samsung-galaxy-watch7.jpg', 'Samsung Galaxy Watch 7', TRUE, 1),
(56, 'products/smartwatches/samsung-galaxy-watch-fe.jpg', 'Samsung Galaxy Watch FE', TRUE, 1),
(57, 'products/smartwatches/garmin-venu4.jpg', 'Garmin Venu 4', TRUE, 1),
(58, 'products/smartwatches/garmin-instinct3.webp', 'Garmin Instinct 3', TRUE, 1),
(59, 'products/smartwatches/garmin-forerunner-965.jpg', 'Garmin Forerunner 965', TRUE, 1),
(60, 'products/smartwatches/garmin-venu-sq2.png', 'Garmin Venu Sq 2', TRUE, 1),
(61, 'products/headphones/sony-wh-1000xm6.jpg', 'Sony WH-1000XM6', TRUE, 1),
(62, 'products/headphones/sony-wf-1000xm5.webp', 'Sony WF-1000XM5', TRUE, 1),
(63, 'products/headphones/sony-linkbuds-s.jpg', 'Sony LinkBuds S', TRUE, 1),
(64, 'products/headphones/sony-wh-ch720n.jpg', 'Sony WH-CH720N', TRUE, 1),
(65, 'products/headphones/bose-quietcomfort-ultra.png', 'Bose QuietComfort Ultra', TRUE, 1),
(66, 'products/headphones/bose-qc-earbuds.webp', 'Bose QuietComfort Earbuds', TRUE, 1),
(67, 'products/headphones/bose-soundlink-max.avif', 'Bose SoundLink Max', TRUE, 1),
(68, 'products/headphones/bose-qc45.webp', 'Bose QuietComfort 45', TRUE, 1),
(69, 'products/headphones/apple-airpods-pro2.jpg', 'Apple AirPods Pro 2', TRUE, 1),
(70, 'products/headphones/apple-airpods-4.webp', 'Apple AirPods 4', TRUE, 1),
(71, 'products/headphones/apple-airpods-maxi.jpg', 'Apple AirPods Max', TRUE, 1),
(72, 'products/headphones/apple-beats-solo4.jpg', 'Apple Beats Solo 4', TRUE, 1);


-- =============================================================
-- TẠO CÁC ATTRIBUTE THEO NHÓM SẢN PHẨM
-- =============================================================

-- 1. ĐIỆN THOẠI
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('Màn hình', 'text', TRUE, 1),
('Chip xử lý', 'text', TRUE, 2),
('RAM', 'select', TRUE, 3),
('Bộ nhớ trong', 'select', TRUE, 4),
('Camera sau', 'text', TRUE, 5),
('Camera trước', 'text', FALSE, 6),
('Pin', 'text', TRUE, 7),
('Hệ điều hành', 'text', TRUE, 8),
('SIM', 'text', FALSE, 9),
('Kháng nước/bụi', 'text', TRUE, 10);

-- 2. LAPTOP
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('CPU', 'text', TRUE, 1),
('RAM', 'select', TRUE, 2),
('Ổ cứng', 'select', TRUE, 3),
('Card đồ họa', 'text', TRUE, 4),
('Màn hình', 'text', TRUE, 5),
('Trọng lượng', 'text', FALSE, 6),
('Pin', 'text', FALSE, 7),
('Hệ điều hành', 'text', TRUE, 8);

-- 3. MÁY TÍNH BẢNG
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('Màn hình', 'text', TRUE, 1),
('Chip xử lý', 'text', TRUE, 2),
('RAM', 'select', TRUE, 3),
('Bộ nhớ', 'select', TRUE, 4),
('Camera sau', 'text', FALSE, 5),
('Camera trước', 'text', FALSE, 6),
('Pin', 'text', FALSE, 7),
('Kết nối', 'text', TRUE, 8);

-- 4. PHỤ KIỆN
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('Dung lượng pin', 'text', TRUE, 1),
('Công suất sạc', 'text', TRUE, 2),
('Cổng kết nối', 'text', TRUE, 3),
('Chống nước', 'text', TRUE, 4),
('Tương thích', 'text', TRUE, 5),
('Chất liệu', 'text', FALSE, 6);

-- 5. ĐỒNG HỒ THÔNG MINH
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('Màn hình', 'text', TRUE, 1),
('Kích thước', 'select', TRUE, 2),
('Chất liệu dây', 'text', TRUE, 3),
('Chống nước', 'text', TRUE, 4),
('Pin', 'text', TRUE, 5),
('Cảm biến', 'text', FALSE, 6),
('Hệ điều hành', 'text', TRUE, 7);

-- 6. TAI NGHE
INSERT INTO attributes (name, type, is_filterable, sort_order) VALUES
('Loại tai nghe', 'select', TRUE, 1),
('Kết nối', 'text', TRUE, 2),
('Chống ồn (ANC)', 'text', TRUE, 3),
('Thời lượng pin', 'text', TRUE, 4),
('Driver', 'text', FALSE, 5),
('Micro', 'text', FALSE, 6),
('Trọng lượng', 'text', FALSE, 7);

-- =============================================================
-- TẠO ATTRIBUTE VALUES (giá trị chọn trước)
-- =============================================================

-- RAM (chung cho nhiều loại)
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '4GB', 1 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '6GB', 2 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '8GB', 3 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '12GB', 4 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '16GB', 5 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '24GB', 6 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '32GB', 7 FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1;

-- Bộ nhớ trong / Ổ cứng / Bộ nhớ
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '64GB', 1 FROM attributes WHERE name IN ('Bộ nhớ trong', 'Bộ nhớ') LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '128GB', 2 FROM attributes WHERE name IN ('Bộ nhớ trong', 'Bộ nhớ') LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '256GB', 3 FROM attributes WHERE name IN ('Bộ nhớ trong', 'Bộ nhớ') LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '512GB', 4 FROM attributes WHERE name IN ('Bộ nhớ trong', 'Bộ nhớ') LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '1TB', 5 FROM attributes WHERE name IN ('Bộ nhớ trong', 'Bộ nhớ') LIMIT 1;

INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '256GB SSD', 1 FROM attributes WHERE name = 'Ổ cứng' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '512GB SSD', 2 FROM attributes WHERE name = 'Ổ cứng' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '1TB SSD', 3 FROM attributes WHERE name = 'Ổ cứng' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '2TB SSD', 4 FROM attributes WHERE name = 'Ổ cứng' LIMIT 1;

-- Kích thước đồng hồ
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '40mm', 1 FROM attributes WHERE name = 'Kích thước' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '41mm', 2 FROM attributes WHERE name = 'Kích thước' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '44mm', 3 FROM attributes WHERE name = 'Kích thước' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '45mm', 4 FROM attributes WHERE name = 'Kích thước' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, '49mm', 5 FROM attributes WHERE name = 'Kích thước' LIMIT 1;

-- Loại tai nghe
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, 'Over-ear', 1 FROM attributes WHERE name = 'Loại tai nghe' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, 'On-ear', 2 FROM attributes WHERE name = 'Loại tai nghe' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, 'In-ear', 3 FROM attributes WHERE name = 'Loại tai nghe' LIMIT 1;
INSERT INTO attribute_values (attribute_id, value, sort_order) SELECT id, 'True Wireless', 4 FROM attributes WHERE name = 'Loại tai nghe' LIMIT 1;

-- =============================================================
-- GÁN THUỘC TÍNH CHO 72 SẢN PHẨM (FULL)
-- =============================================================

-- LẤY ID ATTRIBUTE ĐỂ DỄ DÙNG
SET @attr_man_hinh_phone = (SELECT id FROM attributes WHERE name = 'Màn hình' AND type = 'text' AND sort_order = 1 LIMIT 1);
SET @attr_chip_phone = (SELECT id FROM attributes WHERE name = 'Chip xử lý' AND type = 'text' AND sort_order = 2 LIMIT 1);
SET @attr_ram = (SELECT id FROM attributes WHERE name = 'RAM' AND type = 'select' LIMIT 1);
SET @attr_bo_nho_trong = (SELECT id FROM attributes WHERE name = 'Bộ nhớ trong' AND type = 'select' LIMIT 1);
SET @attr_camera_sau = (SELECT id FROM attributes WHERE name = 'Camera sau' AND type = 'text' LIMIT 1);
SET @attr_camera_truoc = (SELECT id FROM attributes WHERE name = 'Camera trước' AND type = 'text' LIMIT 1);
SET @attr_pin_phone = (SELECT id FROM attributes WHERE name = 'Pin' AND type = 'text' AND sort_order = 7 LIMIT 1);
SET @attr_hd_h_phone = (SELECT id FROM attributes WHERE name = 'Hệ điều hành' AND type = 'text' AND sort_order = 8 LIMIT 1);
SET @attr_khang_nuoc = (SELECT id FROM attributes WHERE name = 'Kháng nước/bụi' AND type = 'text' LIMIT 1);

-- LAPTOP
SET @attr_cpu = (SELECT id FROM attributes WHERE name = 'CPU' LIMIT 1);
SET @attr_o_cung = (SELECT id FROM attributes WHERE name = 'Ổ cứng' LIMIT 1);
SET @attr_card = (SELECT id FROM attributes WHERE name = 'Card đồ họa' LIMIT 1);
SET @attr_man_hinh_laptop = (SELECT id FROM attributes WHERE name = 'Màn hình' AND type = 'text' AND sort_order = 5 LIMIT 1);
SET @attr_pin_laptop = (SELECT id FROM attributes WHERE name = 'Pin' AND type = 'text' AND sort_order = 7 LIMIT 1);
SET @attr_hd_h_laptop = (SELECT id FROM attributes WHERE name = 'Hệ điều hành' AND type = 'text' AND sort_order = 8 LIMIT 1);

-- TABLET
SET @attr_man_hinh_tablet = (SELECT id FROM attributes WHERE name = 'Màn hình' AND type = 'text' AND sort_order = 1 LIMIT 1);
SET @attr_chip_tablet = (SELECT id FROM attributes WHERE name = 'Chip xử lý' AND type = 'text' AND sort_order = 2 LIMIT 1);
SET @attr_bo_nho_tablet = (SELECT id FROM attributes WHERE name = 'Bộ nhớ' AND type = 'select' LIMIT 1);

-- PHỤ KIỆN
SET @attr_dung_luong_pin = (SELECT id FROM attributes WHERE name = 'Dung lượng pin' LIMIT 1);
SET @attr_cong_suat = (SELECT id FROM attributes WHERE name = 'Công suất sạc' LIMIT 1);
SET @attr_cong_ket_noi = (SELECT id FROM attributes WHERE name = 'Cổng kết nối' LIMIT 1);
SET @attr_tuong_thich = (SELECT id FROM attributes WHERE name = 'Tương thích' LIMIT 1);

-- ĐỒNG HỒ
SET @attr_man_hinh_dh = (SELECT id FROM attributes WHERE name = 'Màn hình' AND type = 'text' AND sort_order = 1 LIMIT 1);
SET @attr_kich_thuoc_dh = (SELECT id FROM attributes WHERE name = 'Kích thước' AND type = 'select' LIMIT 1);
SET @attr_chat_lieu_day = (SELECT id FROM attributes WHERE name = 'Chất liệu dây' LIMIT 1);
SET @attr_chong_nuoc_dh = (SELECT id FROM attributes WHERE name = 'Chống nước' LIMIT 1);
SET @attr_pin_dh = (SELECT id FROM attributes WHERE name = 'Pin' AND type = 'text' AND sort_order = 5 LIMIT 1);
SET @attr_cam_bien = (SELECT id FROM attributes WHERE name = 'Cảm biến' LIMIT 1);
SET @attr_hd_h_dh = (SELECT id FROM attributes WHERE name = 'Hệ điều hành' AND type = 'text' AND sort_order = 7 LIMIT 1);

-- TAI NGHE
SET @attr_loai_tai_nghe = (SELECT id FROM attributes WHERE name = 'Loại tai nghe' AND type = 'select' LIMIT 1);
SET @attr_ket_noi_tn = (SELECT id FROM attributes WHERE name = 'Kết nối' LIMIT 1);
SET @attr_anc = (SELECT id FROM attributes WHERE name = 'Chống ồn (ANC)' LIMIT 1);
SET @attr_thoi_luong_pin_tn = (SELECT id FROM attributes WHERE name = 'Thời lượng pin' LIMIT 1);
SET @attr_driver = (SELECT id FROM attributes WHERE name = 'Driver' LIMIT 1);

-- =============================================================
-- GÁN CHO TỪNG SẢN PHẨM
-- =============================================================

-- 1. iPhone 16 Pro Max
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(1, @attr_man_hinh_phone, NULL, '6.9" Super Retina XDR, 120Hz'),
(1, @attr_chip_phone, NULL, 'Apple A18 Pro'),
(1, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(1, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '1TB' LIMIT 1), NULL),
(1, @attr_camera_sau, NULL, '48MP + 48MP + 12MP'),
(1, @attr_camera_truoc, NULL, '12MP'),
(1, @attr_pin_phone, NULL, '4680 mAh'),
(1, @attr_hd_h_phone, NULL, 'iOS 18'),
(1, @attr_khang_nuoc, NULL, 'IP68');

-- 2. iPhone 17
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(2, @attr_man_hinh_phone, NULL, '6.1" OLED, 120Hz'),
(2, @attr_chip_phone, NULL, 'Apple A18'),
(2, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(2, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL),
(2, @attr_camera_sau, NULL, '48MP + 12MP'),
(2, @attr_camera_truoc, NULL, '12MP'),
(2, @attr_pin_phone, NULL, '4000 mAh'),
(2, @attr_hd_h_phone, NULL, 'iOS 18');

-- 3. iPhone Air
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(3, @attr_man_hinh_phone, NULL, '6.7" OLED, 120Hz'),
(3, @attr_chip_phone, NULL, 'Apple A19 Pro'),
(3, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(3, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '512GB' LIMIT 1), NULL),
(3, @attr_camera_sau, NULL, '50MP + 12MP'),
(3, @attr_pin_phone, NULL, '4500 mAh');

-- 4. iPhone SE 4
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(4, @attr_man_hinh_phone, NULL, '6.1" LCD, 60Hz'),
(4, @attr_chip_phone, NULL, 'Apple A17 Pro'),
(4, @attr_ram, (SELECT id FROM attribute_values WHERE value = '6GB' LIMIT 1), NULL),
(4, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '128GB' LIMIT 1), NULL),
(4, @attr_camera_sau, NULL, '12MP'),
(4, @attr_pin_phone, NULL, '3279 mAh');

-- 5. Samsung Galaxy S25 Ultra
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(5, @attr_man_hinh_phone, NULL, '6.9" Dynamic AMOLED 2X, 120Hz'),
(5, @attr_chip_phone, NULL, 'Snapdragon 8 Gen 4'),
(5, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(5, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '1TB' LIMIT 1), NULL),
(5, @attr_camera_sau, NULL, '200MP + 50MP + 10MP + 12MP'),
(5, @attr_pin_phone, NULL, '5000 mAh'),
(5, @attr_hd_h_phone, NULL, 'Android 15, One UI 7'),
(5, @attr_khang_nuoc, NULL, 'IP68');

-- 6. Samsung Galaxy Z Fold 7
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(6, @attr_man_hinh_phone, NULL, '8.0" gập, 7.6" ngoài, 120Hz'),
(6, @attr_chip_phone, NULL, 'Snapdragon 8 Gen 4'),
(6, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(6, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '1TB' LIMIT 1), NULL),
(6, @attr_camera_sau, NULL, '200MP + 12MP + 10MP'),
(6, @attr_pin_phone, NULL, '4600 mAh');

-- 7. Samsung Galaxy S25
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(7, @attr_man_hinh_phone, NULL, '6.2" AMOLED, 120Hz'),
(7, @attr_chip_phone, NULL, 'Snapdragon 8 Gen 4'),
(7, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(7, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL),
(7, @attr_camera_sau, NULL, '50MP + 12MP + 10MP');

-- 8. Samsung Galaxy A56
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(8, @attr_man_hinh_phone, NULL, '6.6" Super AMOLED, 120Hz'),
(8, @attr_chip_phone, NULL, 'Exynos 1580'),
(8, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(8, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL),
(8, @attr_camera_sau, NULL, '50MP + 12MP + 5MP');

-- 9. Google Pixel 10 Pro XL
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(9, @attr_man_hinh_phone, NULL, '6.8" OLED, 120Hz'),
(9, @attr_chip_phone, NULL, 'Tensor G5'),
(9, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(9, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '512GB' LIMIT 1), NULL),
(9, @attr_camera_sau, NULL, '50MP + 48MP + 48MP');

-- 10. Google Pixel 10
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(10, @attr_man_hinh_phone, NULL, '6.3" OLED, 120Hz'),
(10, @attr_chip_phone, NULL, 'Tensor G4'),
(10, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(10, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- 11. Google Pixel 9a
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(11, @attr_man_hinh_phone, NULL, '6.1" OLED, 90Hz'),
(11, @attr_chip_phone, NULL, 'Tensor G3'),
(11, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(11, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '128GB' LIMIT 1), NULL);

-- 12. Google Pixel Fold 2
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(12, @attr_man_hinh_phone, NULL, '7.6" gập, 120Hz'),
(12, @attr_chip_phone, NULL, 'Tensor G4'),
(12, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(12, @attr_bo_nho_trong, (SELECT id FROM attribute_values WHERE value = '512GB' LIMIT 1), NULL);

-- LAPTOPS
-- 13. MacBook Air M4
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(13, @attr_cpu, NULL, 'Apple M4'),
(13, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(13, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '512GB SSD' LIMIT 1), NULL),
(13, @attr_card, NULL, 'Tích hợp 10-core GPU'),
(13, @attr_man_hinh_laptop, NULL, '13.6" Liquid Retina, 60Hz'),
(13, @attr_pin_laptop, NULL, '18 giờ'),
(13, @attr_hd_h_laptop, NULL, 'macOS');

-- 14. MacBook Pro M4 14"
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(14, @attr_cpu, NULL, 'Apple M4 Pro'),
(14, @attr_ram, (SELECT id FROM attribute_values WHERE value = '24GB' LIMIT 1), NULL),
(14, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '1TB SSD' LIMIT 1), NULL),
(14, @attr_card, NULL, 'Tích hợp 20-core GPU'),
(14, @attr_man_hinh_laptop, NULL, '14.2" Liquid Retina XDR, 120Hz');

-- 15. MacBook Pro M4 Max 16"
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(15, @attr_cpu, NULL, 'Apple M4 Max'),
(15, @attr_ram, (SELECT id FROM attribute_values WHERE value = '32GB' LIMIT 1), NULL),
(15, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '2TB SSD' LIMIT 1), NULL),
(15, @attr_card, NULL, 'Tích hợp 40-core GPU'),
(15, @attr_man_hinh_laptop, NULL, '16.2" Liquid Retina XDR, 120Hz');

-- 16. MacBook Air M3
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(16, @attr_cpu, NULL, 'Apple M3'),
(16, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(16, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '512GB SSD' LIMIT 1), NULL),
(16, @attr_man_hinh_laptop, NULL, '13.6" Liquid Retina');

-- 17. Dell XPS 13 (2025)
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(17, @attr_cpu, NULL, 'Intel Core Ultra 9'),
(17, @attr_ram, (SELECT id FROM attribute_values WHERE value = '32GB' LIMIT 1), NULL),
(17, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '1TB SSD' LIMIT 1), NULL),
(17, @attr_card, NULL, 'Intel Arc Graphics'),
(17, @attr_man_hinh_laptop, NULL, '13.4" OLED 3K, 120Hz');

-- 18. Dell Inspiron 16
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(18, @attr_cpu, NULL, 'Intel Core i7-13700H'),
(18, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(18, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '1TB SSD' LIMIT 1), NULL),
(18, @attr_card, NULL, 'RTX 3050 4GB');

-- 19. Dell Latitude 7450
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(19, @attr_cpu, NULL, 'Intel Core Ultra 7'),
(19, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(19, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '512GB SSD' LIMIT 1), NULL),
(19, @attr_man_hinh_laptop, NULL, '14" FHD+');

-- 20. Dell Alienware M16
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(20, @attr_cpu, NULL, 'Intel Core i9-13900HX'),
(20, @attr_ram, (SELECT id FROM attribute_values WHERE value = '32GB' LIMIT 1), NULL),
(20, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '2TB SSD' LIMIT 1), NULL),
(20, @attr_card, NULL, 'RTX 4070 8GB');

-- 21. Lenovo Yoga 9i Gen 10
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(21, @attr_cpu, NULL, 'Intel Core Ultra 7'),
(21, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(21, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '1TB SSD' LIMIT 1), NULL),
(21, @attr_man_hinh_laptop, NULL, '14" OLED 2.8K, 120Hz');

-- 22. Lenovo ThinkPad X1 Carbon
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(22, @attr_cpu, NULL, 'Intel Core Ultra 7'),
(22, @attr_ram, (SELECT id FROM attribute_values WHERE value = '32GB' LIMIT 1), NULL),
(22, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '1TB SSD' LIMIT 1), NULL);

-- 23. Lenovo Legion 7i
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(23, @attr_cpu, NULL, 'Intel Core i9-13980HX'),
(23, @attr_ram, (SELECT id FROM attribute_values WHERE value = '32GB' LIMIT 1), NULL),
(23, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '2TB SSD' LIMIT 1), NULL),
(23, @attr_card, NULL, 'RTX 4060 8GB');

-- 24. Lenovo IdeaPad Slim 5
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(24, @attr_cpu, NULL, 'AMD Ryzen 7 7735HS'),
(24, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(24, @attr_o_cung, (SELECT id FROM attribute_values WHERE value = '512GB SSD' LIMIT 1), NULL);

-- TABLETS
-- 25. iPad 11th Gen
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(25, @attr_man_hinh_tablet, NULL, '10.9" Liquid Retina'),
(25, @attr_chip_tablet, NULL, 'Apple A16'),
(25, @attr_ram, (SELECT id FROM attribute_values WHERE value = '6GB' LIMIT 1), NULL),
(25, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '128GB' LIMIT 1), NULL);

-- 26. iPad Air 7th Gen
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(26, @attr_man_hinh_tablet, NULL, '13" Liquid Retina'),
(26, @attr_chip_tablet, NULL, 'Apple M3'),
(26, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(26, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- 27. iPad Pro M4 11"
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(27, @attr_man_hinh_tablet, NULL, '11" Ultra Retina XDR'),
(27, @attr_chip_tablet, NULL, 'Apple M4'),
(27, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(27, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '1TB' LIMIT 1), NULL);

-- 28. iPad Mini 7
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(28, @attr_man_hinh_tablet, NULL, '8.3" Liquid Retina'),
(28, @attr_chip_tablet, NULL, 'Apple A17 Pro'),
(28, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(28, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- 29. Samsung Galaxy Tab S11 Ultra
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(29, @attr_man_hinh_tablet, NULL, '14.6" Dynamic AMOLED 2X'),
(29, @attr_chip_tablet, NULL, 'Snapdragon 8 Gen 4'),
(29, @attr_ram, (SELECT id FROM attribute_values WHERE value = '16GB' LIMIT 1), NULL),
(29, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '1TB' LIMIT 1), NULL);

-- 30. Samsung Galaxy Tab S10 Plus
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(30, @attr_man_hinh_tablet, NULL, '12.4" AMOLED'),
(30, @attr_chip_tablet, NULL, 'Snapdragon 8 Gen 3'),
(30, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(30, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '512GB' LIMIT 1), NULL);

-- 31. Samsung Galaxy Tab S9 FE
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(31, @attr_man_hinh_tablet, NULL, '10.9" LCD'),
(31, @attr_chip_tablet, NULL, 'Exynos 1380'),
(31, @attr_ram, (SELECT id FROM attribute_values WHERE value = '6GB' LIMIT 1), NULL),
(31, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '128GB' LIMIT 1), NULL);

-- 32. Samsung Galaxy Tab A9+
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(32, @attr_man_hinh_tablet, NULL, '11" LCD, 90Hz'),
(32, @attr_chip_tablet, NULL, 'Snapdragon 695'),
(32, @attr_ram, (SELECT id FROM attribute_values WHERE value = '4GB' LIMIT 1), NULL),
(32, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '64GB' LIMIT 1), NULL);

-- 33. Lenovo Legion Tab Gen 3
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(33, @attr_man_hinh_tablet, NULL, '8.8" LCD, 144Hz'),
(33, @attr_chip_tablet, NULL, 'Snapdragon 8 Gen 2'),
(33, @attr_ram, (SELECT id FROM attribute_values WHERE value = '12GB' LIMIT 1), NULL),
(33, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- 34. Lenovo Tab P12
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(34, @attr_man_hinh_tablet, NULL, '12.7" LCD, 144Hz'),
(34, @attr_chip_tablet, NULL, 'MediaTek Dimensity 7050'),
(34, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(34, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- 35. Lenovo Tab M11
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(35, @attr_man_hinh_tablet, NULL, '11" LCD, 90Hz'),
(35, @attr_chip_tablet, NULL, 'MediaTek Helio G88'),
(35, @attr_ram, (SELECT id FROM attribute_values WHERE value = '4GB' LIMIT 1), NULL),
(35, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '128GB' LIMIT 1), NULL);

-- 36. Lenovo Yoga Tab 13
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(36, @attr_man_hinh_tablet, NULL, '13" 2K LCD'),
(36, @attr_chip_tablet, NULL, 'Snapdragon 870'),
(36, @attr_ram, (SELECT id FROM attribute_values WHERE value = '8GB' LIMIT 1), NULL),
(36, @attr_bo_nho_tablet, (SELECT id FROM attribute_values WHERE value = '256GB' LIMIT 1), NULL);

-- PHỤ KIỆN
-- 37. Anker MagSafe Power Bank 10K
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(37, @attr_dung_luong_pin, NULL, '10000 mAh'),
(37, @attr_cong_suat, NULL, '15W (MagSafe)'),
(37, @attr_cong_ket_noi, NULL, 'USB-C'),
(37, @attr_tuong_thich, NULL, 'iPhone 12-16');

-- 38. Anker Bio-Braided USB-C 240W
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(38, @attr_cong_suat, NULL, '240W'),
(38, @attr_cong_ket_noi, NULL, 'USB-C to USB-C'),
(38, @attr_tuong_thich, NULL, 'MacBook, iPad, Android');

-- 39. Anker Soundcore Speaker
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(39, @attr_dung_luong_pin, NULL, '12 giờ phát nhạc'),
(39, @attr_cong_suat, NULL, '20W'),
(39, @attr_cong_ket_noi, NULL, 'Bluetooth 5.3'),
(39, @attr_tuong_thich, NULL, 'Tất cả thiết bị Bluetooth');

-- 40. Anker USB-C Hub 8-in-1
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(40, @attr_cong_ket_noi, NULL, 'HDMI, USB-A, USB-C, SD, Ethernet'),
(40, @attr_cong_suat, NULL, '100W PD'),
(40, @attr_tuong_thich, NULL, 'MacBook, Windows');

-- 41. Belkin PowerGrip
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(41, @attr_cong_suat, NULL, '65W'),
(41, @attr_cong_ket_noi, NULL, '3-in-1: USB-C, Lightning, Micro'),
(41, @attr_tuong_thich, NULL, 'iPhone, Android');

-- 42. Belkin BoostCharge Pro
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(42, @attr_cong_suat, NULL, '65W GaN'),
(42, @attr_cong_ket_noi, NULL, '2x USB-C, 1x USB-A');

-- 43. Belkin MagSafe Car Mount
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(43, @attr_tuong_thich, NULL, 'iPhone 12-16'),
(43, @attr_cong_ket_noi, NULL, 'MagSafe');

-- 44. Belkin USB-C Cable 2m
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(44, @attr_cong_suat, NULL, '100W'),
(44, @attr_cong_ket_noi, NULL, 'USB-C to USB-C');

-- 45. Apple AirTag (4-pack)
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(45, @attr_tuong_thich, NULL, 'iPhone, iPad'),
(45, @attr_cong_ket_noi, NULL, 'UWB, Bluetooth');

-- 46. Apple MagSafe Charger
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(46, @attr_cong_suat, NULL, '15W'),
(46, @attr_tuong_thich, NULL, 'iPhone 12-16');

-- 47. Apple USB-C to Lightning
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(47, @attr_cong_suat, NULL, '60W'),
(47, @attr_cong_ket_noi, NULL, 'USB-C to Lightning');

-- 48. Apple Magic Keyboard
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(48, @attr_tuong_thich, NULL, 'iPad Pro, iPad Air'),
(48, @attr_cong_ket_noi, NULL, 'Smart Connector');

-- ĐỒNG HỒ
-- 49. Apple Watch Series 11
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(49, @attr_man_hinh_dh, NULL, '1.9" OLED'),
(49, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '45mm' LIMIT 1), NULL),
(49, @attr_chat_lieu_day, NULL, 'Silicone'),
(49, @attr_chong_nuoc_dh, NULL, '50m'),
(49, @attr_pin_dh, NULL, '36 giờ'),
(49, @attr_cam_bien, NULL, 'ECG, SpO2, nhịp tim'),
(49, @attr_hd_h_dh, NULL, 'watchOS 11');

-- 50. Apple Watch Ultra 3
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(50, @attr_man_hinh_dh, NULL, '2.0" OLED'),
(50, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '49mm' LIMIT 1), NULL),
(50, @attr_chong_nuoc_dh, NULL, '100m, lặn sâu'),
(50, @attr_pin_dh, NULL, '72 giờ');

-- 51. Apple Watch SE 3
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(51, @attr_man_hinh_dh, NULL, '1.78" OLED'),
(51, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '44mm' LIMIT 1), NULL),
(51, @attr_pin_dh, NULL, '18 giờ');

-- 52. Apple Watch Series 10
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(52, @attr_man_hinh_dh, NULL, '1.9" OLED'),
(52, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '45mm' LIMIT 1), NULL),
(52, @attr_pin_dh, NULL, '18 giờ');

-- 53. Samsung Galaxy Watch 8
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(53, @attr_man_hinh_dh, NULL, '1.5" AMOLED'),
(53, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '45mm' LIMIT 1), NULL),
(53, @attr_pin_dh, NULL, '48 giờ'),
(53, @attr_hd_h_dh, NULL, 'Wear OS 5');

-- 54. Samsung Galaxy Watch Ultra 2025
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(54, @attr_man_hinh_dh, NULL, '1.5" AMOLED'),
(54, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '47mm' LIMIT 1), NULL),
(54, @attr_pin_dh, NULL, '100 giờ');

-- 55. Samsung Galaxy Watch 7
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(55, @attr_man_hinh_dh, NULL, '1.3" AMOLED'),
(55, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '40mm' LIMIT 1), NULL),
(55, @attr_pin_dh, NULL, '40 giờ');

-- 56. Samsung Galaxy Watch FE
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(56, @attr_man_hinh_dh, NULL, '1.2" AMOLED'),
(56, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '40mm' LIMIT 1), NULL),
(56, @attr_pin_dh, NULL, '30 giờ');

-- 57. Garmin Venu 4
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(57, @attr_man_hinh_dh, NULL, '1.4" AMOLED'),
(57, @attr_kich_thuoc_dh, (SELECT id FROM attribute_values WHERE value = '45mm' LIMIT 1), NULL),
(57, @attr_pin_dh, NULL, '14 ngày'),
(57, @attr_cam_bien, NULL, 'GPS, HR, SpO2, stress');

-- 58. Garmin Instinct 3
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(58, @attr_man_hinh_dh, NULL, 'Monochrome'),
(58, @attr_chong_nuoc_dh, NULL, '100m, MIL-STD'),
(58, @attr_pin_dh, NULL, '28 ngày');

-- 59. Garmin Forerunner 965
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(59, @attr_man_hinh_dh, NULL, '1.4" AMOLED'),
(59, @attr_pin_dh, NULL, '23 ngày'),
(59, @attr_cam_bien, NULL, 'GPS đa băng tần');

-- 60. Garmin Venu Sq 2
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(60, @attr_man_hinh_dh, NULL, '1.41" AMOLED'),
(60, @attr_pin_dh, NULL, '11 ngày');

-- TAI NGHE
-- 61. Sony WH-1000XM6
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(61, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'Over-ear' LIMIT 1), NULL),
(61, @attr_ket_noi_tn, NULL, 'Bluetooth 5.3, LDAC'),
(61, @attr_anc, NULL, 'ANC chủ động, AI'),
(61, @attr_thoi_luong_pin_tn, NULL, '30 giờ (ANC on)'),
(61, @attr_driver, NULL, '40mm');

-- 62. Sony WF-1000XM5
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(62, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'True Wireless' LIMIT 1), NULL),
(62, @attr_anc, NULL, 'ANC tốt nhất phân khúc'),
(62, @attr_thoi_luong_pin_tn, NULL, '8 giờ + 24 giờ hộp');

-- 63. Sony LinkBuds S
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(63, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'True Wireless' LIMIT 1), NULL),
(63, @attr_anc, NULL, 'ANC thích ứng'),
(63, @attr_thoi_luong_pin_tn, NULL, '6 giờ + 14 giờ');

-- 64. Sony WH-CH720N
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(64, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'Over-ear' LIMIT 1), NULL),
(64, @attr_anc, NULL, 'ANC cơ bản'),
(64, @attr_thoi_luong_pin_tn, NULL, '35 giờ');

-- 65. Bose QuietComfort Ultra
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(65, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'Over-ear' LIMIT 1), NULL),
(65, @attr_anc, NULL, 'ANC đỉnh cao, Immersive Audio'),
(65, @attr_thoi_luong_pin_tn, NULL, '24 giờ');

-- 66. Bose QuietComfort Earbuds
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(66, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'True Wireless' LIMIT 1), NULL),
(66, @attr_anc, NULL, 'ANC mạnh'),
(66, @attr_thoi_luong_pin_tn, NULL, '6 giờ + 18 giờ');

-- 67. Bose SoundLink Max
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(67, @attr_loai_tai_nghe, NULL, 'Loa Bluetooth'),
(67, @attr_thoi_luong_pin_tn, NULL, '20 giờ'),
(67, @attr_cong_suat, NULL, '60W');

-- 68. Bose QuietComfort 45
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(68, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'Over-ear' LIMIT 1), NULL),
(68, @attr_anc, NULL, 'ANC cổ điển'),
(68, @attr_thoi_luong_pin_tn, NULL, '24 giờ');

-- 69. Apple AirPods Pro 2
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(69, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'True Wireless' LIMIT 1), NULL),
(69, @attr_anc, NULL, 'ANC thích ứng 2x'),
(69, @attr_thoi_luong_pin_tn, NULL, '6 giờ + 30 giờ');

-- 70. Apple AirPods 4
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(70, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'In-ear' LIMIT 1), NULL),
(70, @attr_thoi_luong_pin_tn, NULL, '5 giờ + 30 giờ');

-- 71. Apple AirPods Max
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(71, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'Over-ear' LIMIT 1), NULL),
(71, @attr_anc, NULL, 'ANC cao cấp'),
(71, @attr_thoi_luong_pin_tn, NULL, '20 giờ');

-- 72. Apple Beats Solo 4
INSERT INTO product_attributes (product_id, attribute_id, attribute_value_id, value_text) VALUES
(72, @attr_loai_tai_nghe, (SELECT id FROM attribute_values WHERE value = 'On-ear' LIMIT 1), NULL),
(72, @attr_thoi_luong_pin_tn, NULL, '50 giờ'),
(72, @attr_ket_noi_tn, NULL, 'Bluetooth 5.3');



-- ====================================
-- THÊM DỮ LIỆU REVIEWS CHO 72 SẢN PHẨM
-- ====================================
-- Thêm một số người dùng mẫu Việt Nam để viết review
INSERT INTO users (username, password, email, full_name, role, email_verified) VALUES
('minh_nguyen', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'minhnguyen@example.com', 'Nguyễn Văn Minh', 'customer', TRUE),
('lan_tran', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'lantran@example.com', 'Trần Thị Lan', 'customer', TRUE),
('hung_pham', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hungpham@example.com', 'Phạm Văn Hùng', 'customer', TRUE),
('hoa_le', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'hoale@example.com', 'Lê Thị Hoa', 'customer', TRUE),
('tuan_vo', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'tuanvo@example.com', 'Võ Anh Tuấn', 'customer', TRUE),
('mai_nguyen', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'mainguyen@example.com', 'Nguyễn Thị Mai', 'customer', TRUE),
('duong_tran', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'duongtran@example.com', 'Trần Văn Dương', 'customer', TRUE),
('thuy_pham', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'thuypham@example.com', 'Phạm Thị Thủy', 'customer', TRUE),
('quang_hoang', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'quanghoang@example.com', 'Hoàng Văn Quang', 'customer', TRUE),
('linh_bui', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi', 'linhbui@example.com', 'Bùi Thị Linh', 'customer', TRUE);

-- Reviews cho điện thoại (ID 1-12)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- iPhone 16 Pro Max
(1, 1, 5, 'Flagship xuất sắc!', 'iPhone 16 Pro Max thực sự đáng giá tiền. Màn hình siêu đẹp, hiệu năng mượt mà, camera chụp ảnh cực kỳ ấn tượng. Pin trâu, sử dụng cả ngày không lo hết.', TRUE, 12, '2024-01-15 10:30:00'),
(1, 2, 4, 'Rất tốt nhưng giá hơi cao', 'Sản phẩm chất lượng cao, nhưng giá thành hơi cao so với mặt bằng chung. Camera chụp đêm cực đỉnh!', TRUE, 8, '2024-01-20 14:22:00'),
(1, 3, 5, 'Xứng đáng từng đồng tiền', 'Tôi đã sử dụng nhiều flagship nhưng iPhone 16 Pro Max thực sự vượt trội. Face ID nhanh, màn hình siêu sáng, âm thanh sống động.', TRUE, 15, '2024-02-05 09:15:00'),

-- iPhone 17
(2, 4, 4, 'Cân bằng hoàn hảo giữa giá và chất lượng', 'iPhone 17 phù hợp với những ai muốn trải nghiệm iOS mà không cần chi quá nhiều tiền. Hiệu năng ổn định, thiết kế đẹp.', TRUE, 6, '2024-02-10 16:45:00'),
(2, 5, 5, 'Hài lòng tuyệt đối', 'Mua được 2 tuần, máy chạy rất mượt. Pin tốt, sạc nhanh. Thiết kế đẹp, cầm chắc tay. Rất đáng mua!', TRUE, 3, '2024-02-18 11:20:00'),

-- iPhone Air
(3, 6, 5, 'Nhẹ mà mạnh mẽ không tưởng', 'Đúng như tên gọi, máy rất nhẹ nhưng hiệu năng thì không đùa được. Phù hợp cho cả công việc và giải trí.', TRUE, 7, '2024-02-22 13:10:00'),
(3, 7, 4, 'Thiết kế ấn tượng, camera tốt', 'Mỏng nhẹ, sang trọng. Camera chụp ảnh rất tự nhiên, màu sắc chân thực. Rất thích!', TRUE, 4, '2024-03-01 15:30:00'),

-- iPhone SE 4
(4, 8, 4, 'Lựa chọn thông minh cho ngân sách hạn chế', 'Giá tốt, hiệu năng ổn. Phù hợp cho người dùng cơ bản, không cần quá nhiều tính năng cao cấp.', TRUE, 5, '2024-02-08 11:20:00'),

-- Samsung Galaxy S25 Ultra
(5, 1, 5, 'Android flagship xuất sắc nhất', 'S25 Ultra cho trải nghiệm Android tốt nhất từ trước đến nay. Màn hình siêu mượt, S Pen rất tiện lợi cho công việc.', TRUE, 18, '2024-01-25 08:45:00'),
(5, 3, 5, 'Camera đỉnh cao, không chê vào đâu được', 'Camera 200MP thực sự khác biệt. Zoom 100x vẫn rõ nét, chụp đêm cực tốt. Quá hài lòng!', TRUE, 22, '2024-02-02 10:15:00'),
(5, 9, 4, 'Máy tốt, pin khỏe', 'Sử dụng được 2 ngày mới phải sạc. Màn hình đẹp, hiệu năng mạnh mẽ. Đáng đồng tiền!', TRUE, 9, '2024-02-15 14:30:00'),

-- Samsung Galaxy Z Fold 7
(6, 2, 4, 'Trải nghiệm màn hình gập tuyệt vời', 'Màn hình lớn rất tốt cho đa nhiệm và giải trí. Tuy nhiên giá vẫn còn cao và máy hơi nặng.', TRUE, 9, '2024-02-08 14:50:00'),
(6, 4, 5, 'Công nghệ đỉnh cao', 'Màn hình gập mượt mà, độ bền tốt. Trải nghiệm đa nhiệm tuyệt vời trên màn hình lớn.', TRUE, 11, '2024-02-20 16:25:00'),

-- Samsung Galaxy S25
(7, 5, 5, 'Cân bằng hoàn hảo', 'Màn hình đẹp, camera tốt, giá hợp lý. Lựa chọn tốt cho những ai không cần flagship cao cấp nhất.', TRUE, 7, '2024-02-15 14:30:00'),

-- Samsung Galaxy A56
(8, 6, 4, 'Tầm trung chất lượng', 'Giá tốt, cấu hình ổn. Phù hợp cho học sinh, sinh viên. Camera chụp ảnh khá đẹp.', TRUE, 4, '2024-02-22 10:45:00'),

-- Google Pixel 10 Pro XL
(9, 7, 5, 'Camera AI tốt nhất thị trường', 'Tính năng AI trên camera Pixel thực sự khác biệt. Ảnh chụp rất tự nhiên, phần mềm tối ưu tốt.', TRUE, 14, '2024-02-14 12:25:00'),
(9, 8, 4, 'Android thuần tuyệt vời', 'Giao diện sạch sẽ, không bloatware. Camera xử lý màu sắc rất chân thực.', TRUE, 8, '2024-02-25 09:15:00'),

-- Google Pixel 10
(10, 9, 4, 'Máy tốt, giá hợp lý', 'Hiệu năng ổn định, camera đẹp. Phù hợp cho người dùng thông thường.', TRUE, 3, '2024-03-02 13:20:00'),

-- Google Pixel 9a
(11, 10, 5, 'Giá rẻ mà chất lượng', 'Bất ngờ với chất lượng của Pixel 9a. Camera rất tốt với mức giá này. Đáng mua!', TRUE, 6, '2024-02-28 15:40:00'),

-- Google Pixel Fold 2
(12, 1, 4, 'Màn hình gập ấn tượng', 'Thiết kế đẹp, màn hình gập mượt. Tuy nhiên giá vẫn còn cao so với các đối thủ.', TRUE, 7, '2024-02-18 11:30:00');

-- Reviews cho Laptop (ID 13-24)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- MacBook Air M4
(13, 2, 5, 'Mỏng nhẹ, hiệu năng đỉnh cao', 'Chip M4 mạnh mẽ bất ngờ trên thân máy mỏng nhẹ. Pin trâu, sử dụng cả ngày không cần sạc. Perfect!', TRUE, 11, '2024-01-18 09:30:00'),
(13, 3, 4, 'Hoàn hảo cho công việc văn phòng', 'Máy chạy êm, không nóng, màn hình Retina đẹp. Phù hợp cho các tác vụ văn phòng và học tập.', TRUE, 7, '2024-01-25 16:20:00'),
(13, 4, 5, 'Sinh viên nên mua', 'Nhẹ, pin lâu, hiệu năng tốt. Làm bài tập, xem phim đều rất ok. Rất hài lòng!', TRUE, 9, '2024-02-05 14:15:00'),

-- MacBook Pro M4 14"
(14, 5, 5, 'Máy trâu cho creative', 'Render video nhanh, màn hình XDR màu sắc chính xác. Đáng đồng tiền cho designer và video editor.', TRUE, 16, '2024-02-05 11:45:00'),
(14, 6, 5, 'Đỉnh cao của sáng tạo', 'Màn hình tuyệt đẹp, màu sắc chính xác. Chip M4 Pro xử lý mọi tác vụ nặng dễ dàng.', TRUE, 12, '2024-02-12 10:20:00'),

-- MacBook Pro M4 Max 16"
(15, 7, 5, 'Quái vật hiệu năng', 'M4 Max thực sự quá mạnh. Render 8K không lag, xử lý mọi tác vụ nặng nhất.', TRUE, 14, '2024-02-18 15:30:00'),

-- MacBook Air M3
(16, 8, 4, 'Giá tốt, chất lượng ổn', 'Mua cho vợ dùng, máy chạy mượt, nhẹ, đẹp. Phù hợp cho công việc văn phòng.', TRUE, 5, '2024-02-22 13:45:00'),

-- Dell XPS 13 (2025)
(17, 9, 4, 'Windows ultrabook tốt nhất', 'Thiết kế đẹp, màn hình viền siêu mỏng. Hiệu năng ổn định, phù hợp cho doanh nhân.', TRUE, 8, '2024-02-12 14:15:00'),
(17, 10, 5, 'Màn hình OLED tuyệt đẹp', 'Màn hình OLED màu sắc sống động, độ tương phản cao. Bàn phím gõ êm tay, rất thích!', TRUE, 12, '2024-02-20 10:30:00'),

-- Dell Inspiron 16
(18, 1, 4, 'Laptop gia đình tốt', 'Màn hình lớn, cấu hình ổn. Phù hợp cho cả làm việc và giải trí gia đình.', TRUE, 6, '2024-02-25 16:20:00'),

-- Dell Latitude 7450
(19, 2, 5, 'Bền bỉ cho doanh nhân', 'Thiết kế chắc chắn, bàn phím tốt. Pin lâu, thích hợp cho đi công tác.', TRUE, 7, '2024-03-01 09:15:00'),

-- Dell Alienware M16
(20, 3, 5, 'Gaming cực đã', 'Chơi game mượt mà, tản nhiệt tốt. Thiết kế gaming đẹp, đèn RGB lung linh.', TRUE, 15, '2024-02-28 14:40:00'),

-- Lenovo Yoga 9i Gen 10
(21, 4, 4, '2-in-1 linh hoạt', 'Vừa là laptop, vừa là tablet. Màn hình cảm ứng tốt, thiết kế sang trọng.', TRUE, 8, '2024-02-15 11:25:00'),

-- Lenovo ThinkPad X1 Carbon
(22, 5, 5, 'Doanh nhân không thể thiếu', 'Vỏ carbon bền chắc, bàn phím gõ tốt nhất phân khúc. Trackpoint rất tiện lợi.', TRUE, 9, '2024-02-25 13:40:00'),

-- Lenovo Legion 7i
(23, 6, 5, 'Gaming workstation', 'Hiệu năng gaming đỉnh cao, tản nhiệt xuất sắc. Màn hình 240Hz mượt mà.', TRUE, 11, '2024-02-20 17:30:00'),

-- Lenovo IdeaPad Slim 5
(24, 7, 4, 'Học tập tốt, giá hợp lý', 'Mỏng nhẹ, cấu hình đủ dùng. Pin tốt, thích hợp cho sinh viên.', TRUE, 5, '2024-02-22 10:15:00');

-- Reviews cho Máy tính bảng (ID 25-36)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- iPad 11th Gen
(25, 8, 4, 'Tablet giá tốt cho học tập', 'Phù hợp cho học tập và giải trí cơ bản. Apple Pencil hỗ trợ tốt cho ghi chú, vẽ vời.', TRUE, 6, '2024-01-22 15:20:00'),
(25, 9, 5, 'Hoàn hảo cho sinh viên', 'Mua cho em học online rất tốt. Màn hình đẹp, hiệu năng ổn định. Rất đáng tiền!', TRUE, 4, '2024-01-30 08:45:00'),

-- iPad Air (7th Gen)
(26, 10, 5, 'Cân bằng hoàn hảo', 'Màn hình lớn, chip M3 mạnh mẽ. Giá tốt hơn iPad Pro nhưng hiệu năng gần như tương đương.', TRUE, 8, '2024-02-05 14:30:00'),

-- iPad Pro M4 11"
(27, 1, 5, 'Tablet mạnh nhất thị trường', 'Chip M4 quá mạnh, có thể thay thế laptop cho nhiều tác vụ. Màn hình OLED đẹp xuất sắc.', TRUE, 13, '2024-02-15 11:30:00'),
(27, 2, 5, 'Đỉnh cao cho sáng tạo', 'Làm design, edit video rất mượt. Apple Pencil Pro chính xác cao. Quá hài lòng!', TRUE, 10, '2024-02-22 16:45:00'),

-- iPad Mini 7
(28, 3, 4, 'Nhỏ gọn, tiện lợi', 'Kích thước perfect cho mang theo. Đọc sách, lướt web rất thoải mái.', TRUE, 5, '2024-02-18 13:20:00'),

-- Samsung Galaxy Tab S11 Ultra
(29, 4, 5, 'Android tablet đỉnh cao', 'Màn hình AMOLED đẹp, S Pen đi kèm rất tiện. Đa nhiệm tốt, có Dex như laptop.', TRUE, 10, '2024-02-22 16:10:00'),
(29, 5, 4, 'Tablet đa năng', 'Làm việc và giải trí đều tốt. Màn hình lớn xem phim rất đã.', TRUE, 7, '2024-02-28 10:35:00'),

-- Samsung Galaxy Tab S10 Plus
(30, 6, 4, 'Chất lượng tốt', 'Màn hình đẹp, hiệu năng ổn. Giá hợp lý hơn bản Ultra.', TRUE, 4, '2024-03-02 14:50:00'),

-- Samsung Galaxy Tab S9 FE
(31, 7, 5, 'Giá rẻ chất lượng', 'Bất ngờ với chất lượng của Tab S9 FE. Màn hình tốt, S Pen đi kèm hữu ích.', TRUE, 6, '2024-02-25 11:15:00'),

-- Samsung Galaxy Tab A9+
(32, 8, 4, 'Tablet gia đình tốt', 'Giá rẻ, màn hình lớn. Phù hợp cho trẻ em học tập và giải trí.', TRUE, 3, '2024-02-20 09:40:00'),

-- Lenovo Legion Tab Gen 3
(33, 9, 5, 'Gaming tablet tuyệt vời', 'Màn hình 144Hz mượt mà, chơi game rất đã. Thiết kế gaming ấn tượng.', TRUE, 8, '2024-02-15 17:25:00'),

-- Lenovo Tab P12
(34, 10, 4, 'Làm việc tốt', 'Màn hình lớn, pin khỏe. Thích hợp cho công việc di động.', TRUE, 4, '2024-02-22 12:30:00'),

-- Lenovo Tab M11
(35, 1, 4, 'Học online tốt', 'Mua cho con học online, máy chạy ổn, giá cả phải chăng.', TRUE, 2, '2024-02-28 15:20:00'),

-- Lenovo Yoga Tab 13
(36, 2, 5, 'Thiết kế độc đáo', 'Chân đế tích hợp rất tiện, xem phim không cần giá đỡ. Âm thanh hay.', TRUE, 7, '2024-03-01 13:45:00');

-- Reviews cho Phụ kiện (ID 37-48)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- Anker MagSafe Power Bank
(37, 3, 5, 'Sạc dự phòng tiện lợi', 'Thiết kế nhỏ gọn, hỗ trợ MagSafe tiện lợi. Dung lượng đủ dùng cả ngày. Rất hài lòng!', TRUE, 8, '2024-01-20 12:15:00'),
(37, 4, 4, 'Chất lượng tốt, giá hơi cao', 'Sạc nhanh, có kickstand rất tiện khi xem phim. Giá hơi cao một chút nhưng chất lượng tốt.', TRUE, 5, '2024-01-28 14:50:00'),

-- Anker Bio-Braided USB-C 240W
(38, 5, 5, 'Cáp chất lượng cao', 'Chất liệu tốt, dẻo dai. Sạc nhanh 240W, tương thích tốt với MacBook.', TRUE, 6, '2024-02-05 10:30:00'),

-- Anker Soundcore Speaker
(39, 6, 4, 'Loa Bluetooth tốt', 'Âm thanh hay, chống nước tốt. Pin lâu, mang đi picnic rất tiện.', TRUE, 4, '2024-02-12 16:20:00'),

-- Anker USB-C Hub 8-in-1
(40, 7, 5, 'Hub đa năng chất lượng', 'Kết nối ổn định, đầy đủ cổng cần thiết. Chất liệu tốt, tản nhiệt ổn.', TRUE, 7, '2024-02-18 14:15:00'),

-- Belkin PowerGrip
(41, 8, 4, 'Sạc 3-in-1 tiện lợi', 'Thiết kế đẹp, sạc được nhiều thiết bị cùng lúc. Giá hơi cao.', TRUE, 3, '2024-02-22 11:40:00'),

-- Belkin BoostCharge Pro
(42, 9, 5, 'Sạc nhanh GaN tốt', 'Nhỏ gọn, sạc nhanh. GaN technology nên không nóng khi sạc.', TRUE, 5, '2024-02-25 15:30:00'),

-- Belkin MagSafe Car Mount
(43, 10, 4, 'Giá đỡ xe hơi tốt', 'Giữ chắc điện thoại, MagSafe tiện lợi. Dễ dàng lắp đặt.', TRUE, 2, '2024-03-02 09:25:00'),

-- Belkin USB-C Cable 2m
(44, 1, 4, 'Cáp chất lượng', 'Bền, sạc nhanh 100W. Độ dài 2m rất tiện sử dụng.', TRUE, 3, '2024-02-28 13:50:00'),

-- Apple AirTag (4-pack)
(45, 2, 5, 'Theo dõi đồ vật tuyệt vời', 'Tìm đồ thất lạc rất hiệu quả. Pin lâu, kết nối ổn định.', TRUE, 9, '2024-02-15 10:15:00'),

-- Apple MagSafe Charger
(46, 3, 4, 'Sạc không dây tiện lợi', 'Sạc nhanh, thiết kế đẹp. Nhưng giá hơi cao so với phụ kiện cùng loại.', TRUE, 3, '2024-02-05 09:30:00'),

-- Apple USB-C to Lightning
(47, 4, 4, 'Cáp chính hãng chất lượng', 'Sạc nhanh, bền. Đáng mua nếu cần cáp chính hãng.', TRUE, 2, '2024-02-20 16:45:00'),

-- Apple Magic Keyboard
(48, 5, 5, 'Bàn phím iPad tuyệt vời', 'Gõ êm, trackpad tốt. Biến iPad thành laptop thực thụ.', TRUE, 8, '2024-02-25 14:20:00');

-- Reviews cho Đồng hồ thông minh (ID 49-60)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- Apple Watch Series 11
(49, 6, 5, 'Đồng hồ thông minh tốt nhất', 'Theo dõi sức khỏe chính xác, thông báo thông minh. Pin tốt hơn các đời trước rất nhiều.', TRUE, 11, '2024-01-25 10:45:00'),
(49, 7, 4, 'Hài lòng với phiên bản mới', 'Màn hình lớn hơn, cảm biến mới chính xác hơn. Tuy nhiên giá vẫn còn cao.', TRUE, 7, '2024-02-02 15:20:00'),
(49, 8, 5, 'Hoàn hảo cho cuộc sống hàng ngày', 'Đeo thoải mái, tính năng đầy đủ. Theo dõi thể thao chính xác.', TRUE, 9, '2024-02-10 13:30:00'),

-- Apple Watch Ultra 3
(50, 9, 5, 'Đồng hồ thể thao đỉnh cao', 'Pin cực trâu, chống nước tốt. Hoàn hảo cho các hoạt động ngoài trời.', TRUE, 12, '2024-02-08 11:15:00'),
(50, 10, 5, 'Phiêu lưu không giới hạn', 'Theo dõi GPS chính xác, độ bền cao. Thích hợp cho hiking, leo núi.', TRUE, 10, '2024-02-15 16:40:00'),

-- Apple Watch SE 3
(51, 1, 4, 'Giá tốt, đủ tính năng', 'Đủ các tính năng cơ bản, giá hợp lý. Phù hợp cho người mới bắt đầu.', TRUE, 5, '2024-02-20 14:25:00'),

-- Apple Watch Series 10
(52, 2, 4, 'Nâng cấp đáng giá', 'Cảm biến giấc ngủ chính xác. Thiết kế đẹp, đeo thoải mái.', TRUE, 6, '2024-02-25 10:50:00'),

-- Samsung Galaxy Watch 8
(53, 3, 4, 'Đồng hồ Android tốt', 'Tương thích tốt với Android, theo dõi giấc ngủ chi tiết. Thiết kế đẹp.', TRUE, 6, '2024-02-10 13:15:00'),
(53, 4, 5, 'Hài lòng với Galaxy Watch 8', 'Pin lâu, màn hình đẹp. Tính năng theo dõi sức khỏe đầy đủ.', TRUE, 8, '2024-02-18 15:35:00'),

-- Samsung Galaxy Watch Ultra 2025
(54, 5, 5, 'Đồng hồ thể thao mạnh mẽ', 'Thiết kế rugged, độ bền cao. Pin 100 giờ rất ấn tượng.', TRUE, 9, '2024-02-22 12:20:00'),

-- Samsung Galaxy Watch 7
(55, 6, 4, 'Cân bằng tốt', 'Đủ tính năng, giá hợp lý. Phù hợp cho người dùng phổ thông.', TRUE, 4, '2024-02-28 11:45:00'),

-- Samsung Galaxy Watch FE
(56, 7, 5, 'Giá rẻ chất lượng', 'Bất ngờ với chất lượng của Watch FE. Đủ tính năng cơ bản, giá tốt.', TRUE, 7, '2024-03-01 14:15:00'),

-- Garmin Venu 4
(57, 8, 5, 'Hoàn hảo cho thể thao', 'Theo dõi GPS chính xác, pin cực trâu. Giao diện thể thao chuyên nghiệp.', TRUE, 9, '2024-02-18 11:30:00'),
(57, 9, 5, 'Đồng hồ fitness tốt nhất', 'Theo dõi sức khỏe toàn diện, pin 14 ngày rất ấn tượng.', TRUE, 11, '2024-02-25 16:50:00'),

-- Garmin Instinct 3
(58, 10, 5, 'Độ bền quân đội', 'Chống sốc, chống nước tốt. Hoàn hảo cho các hoạt động mạnh.', TRUE, 8, '2024-02-20 13:40:00'),

-- Garmin Forerunner 965
(59, 1, 5, 'Runner không thể thiếu', 'GPS đa băng tần chính xác, theo dõi chi tiết các chỉ số chạy bộ.', TRUE, 10, '2024-02-22 15:25:00'),

-- Garmin Venu Sq 2
(60, 2, 4, 'Đồng hồ thông minh giá tốt', 'Pin 11 ngày, đủ tính năng cơ bản. Giá hợp lý cho chất lượng.', TRUE, 5, '2024-02-28 10:30:00');

-- Reviews cho Tai nghe (ID 61-72)
INSERT INTO reviews (product_id, user_id, rating, title, comment, is_approved, helpful_count, created_at) VALUES
-- Sony WH-1000XM6
(61, 3, 5, 'ANC tốt nhất thị trường', 'Chống ồn cực tốt, âm thanh sống động. Thoải mái khi đeo nhiều giờ liên tục.', TRUE, 14, '2024-01-28 14:20:00'),
(61, 4, 5, 'Đáng giá từng đồng tiền', 'Âm bass sâu, treble rõ. ANC xử lý tốt tiếng ồn môi trường. Pin lâu, rất hài lòng!', TRUE, 12, '2024-02-05 16:45:00'),
(61, 5, 4, 'Tai nghe cao cấp xứng đáng', 'Chất âm hay, ANC tốt. Tuy nhiên giá hơi cao so với các đối thủ.', TRUE, 8, '2024-02-12 11:30:00'),

-- Sony WF-1000XM5
(62, 6, 5, 'True wireless ANC xuất sắc', 'ANC tốt nhất phân khúc true wireless. Âm thanh cân bằng, pin tốt.', TRUE, 9, '2024-02-08 15:20:00'),

-- Sony LinkBuds S
(63, 7, 4, 'Nhỏ gọn, âm thanh tốt', 'Thiết kế nhỏ gọn, đeo thoải mái. Âm thanh trong, ANC ổn.', TRUE, 5, '2024-02-15 13:45:00'),

-- Sony WH-CH720N
(64, 8, 4, 'ANC giá rẻ tốt', 'Giá tốt, ANC cơ bản ổn. Phù hợp cho người dùng ngân sách thấp.', TRUE, 4, '2024-02-20 10:15:00'),

-- Bose QuietComfort Ultra
(65, 9, 5, 'Âm thanh tuyệt vời', 'Âm thanh cân bằng, bass mạnh mẽ. Immersive Audio tạo trải nghiệm nghe độc đáo.', TRUE, 10, '2024-02-20 13:40:00'),
(65, 10, 5, 'Thoải mái tuyệt đối', 'Đệm tai êm ái, đeo cả ngày không mỏi. ANC cực tốt.', TRUE, 8, '2024-02-25 16:30:00'),

-- Bose QuietComfort Earbuds
(66, 1, 4, 'True wireless chất lượng', 'ANC mạnh, âm thanh tốt. Pin đủ dùng cả ngày.', TRUE, 6, '2024-03-01 14:20:00'),

-- Bose SoundLink Max
(67, 2, 5, 'Loa Bluetooth đỉnh cao', 'Âm thanh lớn, chất âm hay. Thiết kế bền bỉ, chống nước tốt.', TRUE, 7, '2024-02-22 12:45:00'),

-- Bose QuietComfort 45
(68, 3, 4, 'ANC cổ điển vẫn tốt', 'Dù là đời cũ nhưng ANC vẫn rất tốt. Âm thanh cân bằng, đeo thoải mái.', TRUE, 5, '2024-02-28 11:10:00'),

-- Apple AirPods Pro 2
(69, 4, 4, 'Tai nghe Apple tốt', 'Tích hợp tốt với hệ sinh thái Apple. ANC cải thiện so với đời trước.', TRUE, 8, '2024-02-12 10:15:00'),
(69, 5, 5, 'Hoàn hảo cho iPhone', 'Kết nối nhanh, âm thanh hay. Transparency mode rất tự nhiên.', TRUE, 11, '2024-02-18 15:40:00'),

-- Apple AirPods 4
(70, 6, 4, 'Tai nghe giá tốt', 'Âm thanh ổn, giá hợp lý. Phù hợp cho người dùng cơ bản.', TRUE, 4, '2024-02-25 13:25:00'),

-- Apple AirPods Max
(71, 7, 5, 'Over-ear cao cấp', 'Âm thanh xuất sắc, ANC tuyệt vời. Chất liệu cao cấp, đeo thoải mái.', TRUE, 9, '2024-03-02 16:15:00'),

-- Apple Beats Solo 4
(72, 8, 4, 'Tai nghe on-ear tốt', 'Âm bass mạnh, pin cực lâu. Thiết kế trẻ trung, màu sắc đẹp.', TRUE, 6, '2024-02-20 14:50:00');