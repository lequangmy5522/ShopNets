<?php
// Sửa đường dẫn require
require_once __DIR__ . '/../includes/database.php';
require_once __DIR__ . '/../includes/functions.php';

$database = new Database();
$db = $database->getConnection();

$query = "
    SELECT 
        p.id, p.name, p.price, p.compare_price,
        pi.image_path
    FROM products p
    LEFT JOIN product_images pi ON p.id = pi.product_id AND pi.is_primary = TRUE
    WHERE p.flash_sale = 1 
      AND p.is_active = 1 
      AND p.quantity > 0
      AND p.compare_price > p.price
    ORDER BY (p.compare_price - p.price) DESC
    LIMIT 8
";

try {
    $stmt = $db->prepare($query);
    $stmt->execute();
    $products = $stmt->fetchAll(PDO::FETCH_ASSOC);
} catch (PDOException $e) {
    error_log("Flash Sale Query Error: " . $e->getMessage());
    $products = [];
}

// Kiểm tra xem có sản phẩm flash sale không
if (empty($products)) {
    echo '<div class="text-center w-100 p-5 text-muted">Không có sản phẩm Flash Sale nào hiện tại.</div>';
    exit;
}

foreach ($products as $p):
    // Sửa phần lấy ảnh - dùng cùng logic với index.php
    $img_src = 'https://via.placeholder.com/300x200?text=No+Image';
    
    if (!empty($p['image_path'])) {
        // Kiểm tra file tồn tại với đường dẫn đúng
        $image_full_path = __DIR__ . '/../assets/images/' . $p['image_path'];
        if (file_exists($image_full_path)) {
            $img_src = 'assets/images/' . $p['image_path'];
        } else {
            // Log để debug
            error_log("Image not found: " . $image_full_path);
        }
    }
    
    $discount_percent = $p['compare_price'] > 0 ? round((($p['compare_price'] - $p['price']) / $p['compare_price']) * 100) : 0;
?>
    <div class="grid__col col-3">
        <div class="product-card flash-sale-card">
            <div class="product-image">
                <img src="<?= htmlspecialchars($img_src) ?>" 
                     alt="<?= htmlspecialchars($p['name']) ?>"
                     loading="lazy"
                     onerror="this.src='https://via.placeholder.com/300x200?text=No+Image'">
                <div class="product-badge discount-badge">
                    -<?= $discount_percent ?>%
                </div>
                <div class="product-overlay">
                    <a href="pages/main/product-detail.php?id=<?= $p['id'] ?>" class="btn-view-detail">
                        Xem chi tiết
                    </a>
                </div>
            </div>
            <div class="product-info">
                <h3 class="product-title"><?= htmlspecialchars($p['name']) ?></h3>
                <div class="product-price">
                    <span class="old-price"><?= number_format($p['compare_price']) ?>đ</span>
                    <span class="current-price"><?= number_format($p['price']) ?>đ</span>
                </div>
                <div class="product-actions">
                    <button class="btn btn-outline-primary action-btn" data-id="<?= $p['id'] ?>" data-action="buy">
                        Mua ngay
                    </button>
                    <button class="btn btn-primary action-btn" data-id="<?= $p['id'] ?>" data-action="cart">
                        Thêm vào giỏ
                    </button>
                </div>
            </div>
        </div>
    </div>
<?php endforeach; ?>