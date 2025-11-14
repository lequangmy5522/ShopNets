<!-- includes/product-card.php -->

<?php
$img_sql = "SELECT image_path FROM product_images WHERE product_id = ? AND is_primary = 1 LIMIT 1";
$stmt = $db->prepare($img_sql);
$stmt->execute([$p['id']]);
$img = $stmt->fetchColumn();
$src = $img && file_exists("../assets/images/$img") ? "../assets/images/$img" : 'https://via.placeholder.com/300x300/64748b/fff?text=No+Image';
?>

<div class="product-card">
    <div class="product-image">
        <img src="<?php echo $src; ?>" alt="<?php echo htmlspecialchars($p['name']); ?>" class="product-img-full">

        <!-- CHỈ HIỆN BADGE GIẢM GIÁ -->
        <?php if ($p['compare_price'] > $p['price']): ?>
            <div class="product-badge discount-badge">
                -<?php echo round(100 - ($p['price'] / $p['compare_price'] * 100)); ?>%
            </div>
        <?php endif; ?>

        <!-- BỎ BADGE "MỚI" HOÀN TOÀN -->

        <div class="product-overlay">
            <a href="product-detail.php?id=<?php echo $p['id']; ?>" class="btn details-btn">
                Chi tiết
            </a>
        </div>
    </div>
    <div class="product-info">
        <h5 class="product-title"><?php echo htmlspecialchars($p['name']); ?></h5>
        <p class="product-category"><?php echo htmlspecialchars($p['category_name']); ?></p>
        <div class="product-price">
            <?php if ($p['compare_price'] > $p['price']): ?>
                 <span class="old-price"><?php echo number_format($p['compare_price'], 0, ',', '.'); ?>₫</span>
            <?php endif; ?>
            <span class="current-price"><?php echo number_format($p['price'], 0, ',', '.'); ?>₫</span>
        </div>
        <div class="d-flex gap-1">
            <?php if (isset($_SESSION['user_id'])): ?>
                <button class="btn btn-outline-primary btn-sm flex-fill add-to-cart" data-id="<?php echo $p['id']; ?>">Thêm</button>
                <button class="btn btn-warning btn-sm flex-fill buy-now" data-id="<?php echo $p['id']; ?>">Mua</button>
            <?php else: ?>
                <button class="btn btn-outline-primary btn-sm flex-fill" onclick="showAuthModal()">Thêm</button>
                <button class="btn btn-warning btn-sm flex-fill" onclick="showAuthModal()">Mua</button>
            <?php endif; ?>
        </div>
    </div>
</div>