<?php
// functions.php - ĐÃ ĐƯỢC VIẾT LẠI HOÀN TOÀN CHO DATABASE shopnets
// Chỉ sử dụng các bảng: categories, products, orders, order_items, users, admin, settings

/**
 * Lấy tất cả danh mục
 */
function getCategories($db) {
    $sql = "SELECT * FROM categories ORDER BY name";
    $stmt = $db->query($sql);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Lấy sản phẩm
 */
function getNewProducts($db, $limit = 8) {
    // Ép kiểu số nguyên để tránh lỗi SQL syntax với LIMIT
    $limit = (int)$limit;
    if ($limit < 1) $limit = 8;

    $sql = "SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.name 
            WHERE p.inventory > 0 
            ORDER BY p.created_at DESC 
            LIMIT $limit";

    try {
        $stmt = $db->query($sql);
        return $stmt->fetchAll(PDO::FETCH_ASSOC);
    } catch (Exception $e) {
        error_log("getNewProducts error: " . $e->getMessage());
        return [];
    }
}

/**
 * Lấy sản phẩm theo ID
 */
function getProductById($db, $product_id) {
    $sql = "SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.name 
            WHERE p.id = ? AND p.inventory > 0";
    $stmt = $db->prepare($sql);
    $stmt->execute([$product_id]);
    return $stmt->fetch(PDO::FETCH_ASSOC);
}

/**
 * Lấy sản phẩm theo danh mục (dùng tên category vì không có category_id)
 */
function getProductsByCategory($db, $category_name, $limit = 12) {
    $sql = "SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.name 
            WHERE p.category = ? AND p.inventory > 0 
            ORDER BY p.created_at DESC 
            LIMIT ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$category_name, $limit]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Tìm kiếm sản phẩm
 */
function searchProducts($db, $keyword, $limit = 12) {
    $keyword = "%$keyword%";
    $sql = "SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.name 
            WHERE (p.name LIKE ? OR p.description LIKE ?) 
              AND p.inventory > 0 
            ORDER BY p.created_at DESC 
            LIMIT ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$keyword, $keyword, $limit]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Thêm vào giỏ hàng (session)
 */
function addToCart($product_id, $quantity = 1) {
    if (!isset($_SESSION['cart'])) {
        $_SESSION['cart'] = [];
    }
    $quantity = max(1, (int)$quantity);
    if (isset($_SESSION['cart'][$product_id])) {
        $_SESSION['cart'][$product_id] += $quantity;
    } else {
        $_SESSION['cart'][$product_id] = $quantity;
    }
}

/**
 * Lấy giỏ hàng với thông tin sản phẩm
 */
function getCartItems($db) {
    if (empty($_SESSION['cart'])) return [];

    $ids = array_keys($_SESSION['cart']);
    $placeholders = str_repeat('?,', count($ids) - 1) . '?';
    
    $sql = "SELECT p.*, c.name as category_name 
            FROM products p 
            LEFT JOIN categories c ON p.category = c.name 
            WHERE p.id IN ($placeholders) AND p.inventory > 0";
    
    $stmt = $db->prepare($sql);
    $stmt->execute($ids);
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $cart = [];
    foreach ($products as $p) {
        $cart[] = [
            'product' => $p,
            'quantity' => $_SESSION['cart'][$p['id']]
        ];
    }
    return $cart;
}

/**
 * Tính tổng giỏ hàng
 */
function getCartTotal($db) {
    $total = 0;
    foreach (getCartItems($db) as $item) {
        $total += $item['product']['price'] * $item['quantity'];
    }
    return $total;
}

function getCartCount() {
    return isset($_SESSION['cart']) ? array_sum($_SESSION['cart']) : 0;
}

/**
 * Xóa sản phẩm khỏi giỏ
 */
function removeFromCart($product_id) {
    if (isset($_SESSION['cart'][$product_id])) {
        unset($_SESSION['cart'][$product_id]);
    }
}

function clearCart() {
    unset($_SESSION['cart']);
}

/**
 * Định dạng tiền tệ
 */
function formatPrice($price) {
    return number_format($price, 0, ',', '.') . '₫';
}

/**
 * Lấy ảnh sản phẩm
 */
function getProductImage($image) {
    if (empty($image)) {
        return 'https://via.placeholder.com/300x300?text=No+Image';
    }
    $path = "../assets/images/" . $image;
    return file_exists($path) ? $path : 'https://via.placeholder.com/300x300?text=No+Image';
}

/**
 * Lấy cài đặt website
 */
function getSetting($db, $key) {
    $sql = "SELECT setting_value FROM settings WHERE setting_key = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$key]);
    $row = $stmt->fetch(PDO::FETCH_ASSOC);
    return $row['setting_value'] ?? '';
}

/**
 * Lấy tất cả cài đặt
 */
function getAllSettings($db) {
    $sql = "SELECT setting_key, setting_value FROM settings";
    $stmt = $db->query($sql);
    $rows = $stmt->fetchAll(PDO::FETCH_ASSOC);
    $settings = [];
    foreach ($rows as $row) {
        $settings[$row['setting_key']] = $row['setting_value'];
    }
    return $settings;
}

/**
 * Lấy đơn hàng của user
 */
function getUserOrders($db, $user_id) {
    $sql = "SELECT o.*, COUNT(oi.id) as item_count 
            FROM orders o 
            LEFT JOIN order_items oi ON o.id = oi.order_id 
            WHERE o.user_id = ? 
            GROUP BY o.id 
            ORDER BY o.created_at DESC";
    $stmt = $db->prepare($sql);
    $stmt->execute([$user_id]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}

/**
 * Lấy chi tiết đơn hàng
 */
function getOrderItems($db, $order_id) {
    $sql = "SELECT oi.*, p.name as product_name, p.image 
            FROM order_items oi 
            LEFT JOIN products p ON oi.product_id = p.id 
            WHERE oi.order_id = ?";
    $stmt = $db->prepare($sql);
    $stmt->execute([$order_id]);
    return $stmt->fetchAll(PDO::FETCH_ASSOC);
}




// Thay thế hàm gây lỗi bằng phiên bản an toàn
function getLatestProductsByBrand($db, $limit = 2) {
    // Trả về rỗng vì không có bảng brands
    return [];
}

function getBrands($db) {
    return [];
}

function getLatestPosts($db, $limit = 3) {
    return [];
}

function getProductRating($db, $product_id) {
    return 0;
}

function getReviewCount($db, $product_id) {
    return 0;
}