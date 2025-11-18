<?php
if (session_status() == PHP_SESSION_NONE) session_start();
require_once '../../includes/database.php';
require_once '../../includes/functions.php';

$db = (new Database())->getConnection();

$product_id = $_GET['id'] ?? 0;
if (!$product_id || !is_numeric($product_id)) {
    header("Location: ../../index.php");
    exit();
}

// LẤY THÔNG TIN SẢN PHẨM - CHỈ DÙNG BẢNG products
$stmt = $db->prepare("SELECT * FROM products WHERE id = ? LIMIT 1");
$stmt->execute([$product_id]);
$product = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$product) {
    header("Location: ../../index.php");
    exit();
}
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title><?= htmlspecialchars($product['name']) ?> - ShopNets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb; --danger: #ef4444; --success: #10b981; --gray: #94a3b8;
            --dark: #1e293b; --light: #f8fafc; --border: #e2e8f0; --radius: 16px;
        }
        body { background: #f1f5f9; font-family: 'Inter', sans-serif; padding-top: 136px; color: #333; }
        .container { max-width: 1200px; }
        .breadcrumb {
            background: white;
            border-radius: var(--radius);
            padding: 1.5rem 2rem;
            box-shadow: var(--shadow-sm);
            font-size: 1.7rem !important;
            margin-bottom: 2.4rem;
        }
        .breadcrumb-item a {
            color: var(--primary);
            text-decoration: none;
            font-weight: 600;
            font-size: 1.7rem !important;
        }
        .breadcrumb-item.active { 
            color: var(--dark); 
            font-weight: 500;
            font-size: 1.7rem !important;
        }
        .breadcrumb-item + .breadcrumb-item::before {
            content: "»";
            color: #94a3b8;
            font-weight: bold;
            padding: 0 0.8rem;
        }
        .product-gallery { background: white; padding: 30px; border-radius: var(--radius); box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .main-image { height: 500px; border-radius: 16px; overflow: hidden; background: #f8fafc; margin-bottom: 20px; }
        .main-image img { width: 100%; height: 100%; object-fit: contain; transition: transform 0.4s; }
        .main-image img:hover { transform: scale(1.05); }
        .product-info { background: white; padding: 30px; border-radius: var(--radius); box-shadow: 0 4px 20px rgba(0,0,0,0.1); }
        .product-title { font-size: 2.8rem; font-weight: 700; color: var(--dark); margin-bottom: 16px; }
        .product-price { font-size: 2.8rem; font-weight: 700; color: var(--primary); margin: 20px 0; }
        .stock-status { color: var(--success); font-weight: 600; font-size: 1.6rem; margin: 16px 0; }
        .quantity-controls { display: flex; align-items: center; border: 2px solid var(--border); border-radius: 12px; overflow: hidden; width: fit-content; }
        .quantity-btn { width: 50px; height: 50px; background: white; border: none; font-size: 1.8rem; cursor: pointer; }
        .quantity-btn:hover { background: var(--primary); color: white; }
        .quantity-input { width: 80px; height: 50px; text-align: center; border: none; border-left: 2px solid var(--border); border-right: 2px solid var(--border); font-weight: bold; }
        .btn-custom { padding: 14px 30px; border-radius: 50px; font-weight: 600; font-size: 1.6rem; min-width: 200px; }
        .btn-primary-custom { background: var(--primary); color: white; border: none; }
        .btn-primary-custom:hover { background: #1d4ed8; transform: translateY(-3px); box-shadow: 0 8px 25px rgba(37,99,235,0.4); }
        .btn-outline-custom { border: 2px solid var(--primary); color: var(--primary); background: transparent; }
        .btn-outline-custom:hover { background: var(--primary); color: white; }
        .description { background: white; padding: 30px; border-radius: var(--radius); margin-top: 30px; box-shadow: 0 4px 20px rgba(0,0,0,0.1); font-size: 1.5rem; line-height: 1.8; }
        .back-to-top { position: fixed; bottom: 30px; right: 30px; width: 50px; height: 50px; background: var(--primary); color: white; border-radius: 50%; display: none; align-items: center; justify-content: center; font-size: 1.8rem; box-shadow: 0 4px 15px rgba(0,0,0,0.3); z-index: 9999; }
        .back-to-top.show { display: flex; }
    </style>
</head>
<body>

<?php include '../../includes/header.php'; ?>

<div class="container">
    <!-- Breadcrumb -->
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?= BASE_URL ?>index.php">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="<?= BASE_URL ?>pages/main/products.php">Sản phẩm</a></li>
            <li class="breadcrumb-item active" aria-current="page">
                <?= htmlspecialchars($product['name']) ?>
            </li>
        </ol>
    </nav>

    <div class="row g-5">
        <!-- Ảnh sản phẩm -->
        <div class="col-lg-6">
            <div class="product-gallery">
                <div class="main-image">
                    <?php 
                    $image_path = !empty($product['image']) 
                        ? '../../../admin/assets/images/uploads/' . $product['image'] 
                        : 'https://via.placeholder.com/600x600?text=No+Image';
                    ?>
                    <img src="<?= $image_path ?>" alt="<?= htmlspecialchars($product['name']) ?>">
                </div>
            </div>
        </div>

        <!-- Thông tin sản phẩm -->
        <div class="col-lg-6">
            <div class="product-info">
                <h1 class="product-title"><?= htmlspecialchars($product['name']) ?></h1>

                <div class="product-price">
                    <?= number_format($product['price']) ?>đ
                </div>

                <div class="stock-status">
                    Còn hàng (<?= $product['inventory'] ?> sản phẩm)
                </div>

                <div class="quantity-selector mt-4 d-flex align-items-center">
                    <span class="me-3">Số lượng:</span>
                    <div class="quantity-controls">
                        <button class="quantity-btn" id="decrease">-</button>
                        <input type="number" class="quantity-input" id="quantity" value="1" min="1" max="<?= $product['inventory'] ?>">
                        <button class="quantity-btn" id="increase">+</button>
                    </div>
                </div>

                <div class="d-flex gap-3 mt-4 flex-wrap">
                    <button class="btn-custom btn-outline-custom add-to-cart" data-id="<?= $product['id'] ?>">
                        Thêm vào giỏ hàng
                    </button>
                    <button class="btn-custom btn-primary-custom buy-now" data-id="<?= $product['id'] ?>">
                        Mua ngay
                    </button>
                </div>

                <div class="mt-4 p-4 bg-light rounded">
                    <div class="d-flex align-items-center gap-3 mb-3"> Miễn phí vận chuyển toàn quốc</div>
                    <div class="d-flex align-items-center gap-3 mb-3"> Bảo hành chính hãng 12 tháng</div>
                    <div class="d-flex align-items-center gap-3"> Đổi trả dễ dàng trong 7 ngày</div>
                </div>
            </div>
        </div>
    </div>

    <!-- Mô tả sản phẩm -->
    <div class="description">
        <h3 class="mb-4">Mô tả sản phẩm</h3>
        <?php if (!empty($product['description'])): ?>
            <?= nl2br(htmlspecialchars($product['description'])) ?>
        <?php else: ?>
            <p class="text-muted">Chưa có mô tả chi tiết cho sản phẩm này.</p>
        <?php endif; ?>
    </div>
</div>

<?php include '../../includes/footer.php'; ?>

<button class="back-to-top" id="backToTop">Up</button>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
    // Số lượng
    $('#increase').click(() => {
        let q = $('#quantity');
        if (parseInt(q.val()) < <?= $product['inventory'] ?>) q.val(parseInt(q.val()) + 1);
    });
    $('#decrease').click(() => {
        let q = $('#quantity');
        if (parseInt(q.val()) > 1) q.val(parseInt(q.val()) - 1);
    });

    // Thêm giỏ / Mua ngay
    $('.add-to-cart, .buy-now').click(function() {
        const isBuyNow = $(this).hasClass('buy-now');
        const qty = $('#quantity').val();

        <?php if (isset($_SESSION['user_id'])): ?>
            $.post('../../ajax/add_to_cart.php', {
                product_id: <?= $product['id'] ?>,
                quantity: qty
            }, function(res) {
                if (res.success) {
                    alert(isBuyNow ? 'Đã chuyển đến thanh toán!' : 'Đã thêm vào giỏ hàng!');
                    if (isBuyNow) location.href = '../../pages/main/checkout.php';
                } else {
                    alert(res.message || 'Có lỗi xảy ra!');
                }
            }, 'json');
        <?php else: ?>
            alert('Vui lòng đăng nhập để mua hàng!');
            location.href = '../../auth/login.php';
        <?php endif; ?>
    });

    // Back to top
    $(window).scroll(() => $('#backToTop').toggleClass('show', $(window).scrollTop() > 300));
    $('#backToTop').click(() => $('html, body').animate({scrollTop: 0}, 500));
</script>
</body>
</html>