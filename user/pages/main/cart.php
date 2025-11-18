<?php
// pages/main/cart.php
session_start();
require_once '../../includes/database.php';
require_once '../../includes/functions.php';
require_once '../../includes/config.php';

$database = new Database();
$db = $database->getConnection();

$success = '';
$cart_items = [];
$cart_total = 0;
$cart_count = 0;

// XỬ LÝ POST
if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if (isset($_POST['update_cart']) && isset($_POST['quantity']) && is_array($_POST['quantity'])) {
        foreach ($_POST['quantity'] as $product_id => $quantity) {
            $quantity = max(1, (int)$quantity);
            if ($quantity >= 1) {
                $_SESSION['cart'][$product_id] = $quantity;
            } else {
                unset($_SESSION['cart'][$product_id]);
            }
        }
        $success = 'Giỏ hàng đã được cập nhật!';
    }
    elseif (isset($_POST['remove_item']) && is_numeric($_POST['remove_item'])) {
        $id = (int)$_POST['remove_item'];
        unset($_SESSION['cart'][$id]);
        $success = 'Đã xóa sản phẩm khỏi giỏ hàng!';
    }
    elseif (isset($_POST['clear_cart'])) {
        unset($_SESSION['cart']);
        $success = 'Đã xóa toàn bộ giỏ hàng!';
    }
}

// LẤY DỮ LIỆU GIỎ HÀNG + ẢNH SẢN PHẨM
if (!empty($_SESSION['cart']) && is_array($_SESSION['cart'])) {
    $ids = array_keys($_SESSION['cart']);
    if (!empty($ids)) {
        $placeholders = str_repeat('?,', count($ids) - 1) . '?';
        // ĐÃ THÊM p.image VÀO ĐÂY
        $sql = "SELECT p.id, p.name, p.price, p.image, p.inventory, c.name as category_name 
                FROM products p 
                LEFT JOIN categories c ON p.category = c.name 
                WHERE p.id IN ($placeholders)";
        
        $stmt = $db->prepare($sql);
        $stmt->execute($ids);
        $products = $stmt->fetchAll(PDO::FETCH_ASSOC);

        foreach ($products as $product) {
            $qty = $_SESSION['cart'][$product['id']] ?? 0;
            if ($qty > 0) {
                $cart_items[] = [
                    'product' => $product,
                    'quantity' => $qty
                ];
                $cart_total += $product['price'] * $qty;
            }
        }
    }
}
$cart_count = count($cart_items);
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Giỏ Hàng - ShopNets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        *{margin:0;padding:0;box-sizing:border-box}
        html{font-size:68%;font-family:'Inter',sans-serif}
        body{background:#f1f5f9;color:#1e293b;min-height:100vh;padding-top:80px;display:flex;flex-direction:column}
        :root{
            --primary:#2563eb;--primary-dark:#1d4ed8;--dark:#1e293b;--gray:#94a3b8;--danger:#ef4444;--border:#e2e8f0;
            --shadow-sm:0 1px 3px rgba(0,0,0,0.1);--shadow:0 6px 20px rgba(0,0,0,0.12);
            --radius:14px;--radius-lg:20px;
        }
        .container{max-width:1200px;margin:0 auto;padding:0 15px}

        /* Breadcrumb */
        .breadcrumb{background:white;border-radius:var(--radius);padding:1.5rem 2rem;box-shadow:var(--shadow-sm);font-size:1.7rem !important;margin-bottom:2.4rem}
        .breadcrumb-item a{color:var(--primary);text-decoration:none;font-weight:600}
        .breadcrumb-item.active{color:var(--dark);font-weight:500}

        /* Cart */
        .cart-card{background:white;border-radius:var(--radius-lg);box-shadow:var(--shadow);overflow:hidden;margin-bottom:2rem}
        .cart-header{background:linear-gradient(135deg,var(--primary),var(--primary-dark));color:white;padding:2rem 2.4rem;display:flex;justify-content:space-between;align-items:center}
        .cart-title{font-size:2.2rem;font-weight:700}
        .cart-items{padding:2.4rem}
        .cart-item{display:flex;align-items:center;gap:2rem;padding:1.8rem 0;border-bottom:1px dashed var(--border)}
        .cart-item:last-child{border-bottom:none}

        /* ẢNH SẢN PHẨM ĐẸP */
        .item-image{
            width:110px;height:110px;flex-shrink:0;overflow:hidden;border-radius:var(--radius);box-shadow:var(--shadow-sm);background:white;
        }
        .item-image img{width:100%;height:100%;object-fit:contain;padding:8px;}

        .item-details{flex:1}
        .item-name{font-size:1.75rem;font-weight:600;color:var(--dark);margin-bottom:.4rem}
        .item-category{font-size:1.4rem;color:var(--gray);margin-bottom:.6rem}
        .item-price{font-size:1.9rem;font-weight:700;color:var(--primary)}

        .quantity-control{display:flex;border:1.5px solid var(--border);border-radius:var(--radius);overflow:hidden;background:white}
        .quantity-btn{width:44px;height:44px;border:none;background:transparent;cursor:pointer;font-size:1.8rem}
        .quantity-btn:hover{background:var(--primary);color:white}
        .quantity-input{width:70px;height:44px;border:none;text-align:center;font-weight:600;font-size:1.5rem}
        .remove-btn{width:44px;height:44px;border:1.5px solid var(--danger);background:transparent;color:var(--danger);border-radius:var(--radius);cursor:pointer;display:flex;align-items:center;justify-content:center}
        .remove-btn:hover{background:var(--danger);color:white}

        .cart-summary{background:white;border-radius:var(--radius-lg);box-shadow:var(--shadow);padding:2.4rem;position:sticky;top:120px}
        .summary-title{font-size:1.9rem;font-weight:700;border-bottom:1px solid var(--border);padding-bottom:1rem;margin-bottom:1.5rem}
        .summary-row{display:flex;justify-content:space-between;margin-bottom:1rem;font-size:1.6rem}
        .summary-total{font-size:2.1rem;font-weight:700;color:var(--primary);border-top:2px solid var(--border);padding-top:1.2rem;margin-top:1.2rem}
        .checkout-btn{display:block;width:100%;padding:1.6rem;background:linear-gradient(135deg,var(--primary),var(--primary-dark));color:white;border:none;border-radius:50px;font-size:1.7rem;font-weight:600;margin-top:2rem;text-align:center;text-decoration:none;transition:all .3s}
        .checkout-btn:hover{transform:translateY(-3px);box-shadow:0 12px 30px rgba(37,99,235,0.4)}
    </style>
</head>
<body>
    <?php if (file_exists('../../includes/header.php')) include '../../includes/header.php'; ?>

    <div class="container mt-3">
        <nav aria-label="breadcrumb">
            <ol class="breadcrumb">
                <li class="breadcrumb-item"><a href="<?= BASE_URL ?>index.php">Trang chủ</a></li>
                <li class="breadcrumb-item active">Giỏ hàng</li>
            </ol>
        </nav>
    </div>

    <section class="container" style="flex:1">
        <?php if ($success): ?>
            <div class="alert alert-success alert-dismissible fade show mb-4">
                <?= $success ?>
                <button type="button" class="btn-close" data-bs-dismiss="alert"></button>
            </div>
        <?php endif; ?>

        <?php if (empty($cart_items)): ?>
            <div class="text-center py-5">
                <i class="bi bi-cart-x" style="font-size:6rem;color:#ddd"></i>
                <h3 class="my-4">Giỏ hàng trống</h3>
                <a href="<?= BASE_URL ?>index.php" class="btn btn-primary btn-lg px-5">Mua sắm ngay</a>
            </div>
        <?php else: ?>
            <form method="POST" id="cart-form">
                <div class="row">
                    <div class="col-lg-8">
                        <div class="cart-card">
                            <div class="cart-header">
                                <h3 class="cart-title">Sản phẩm trong giỏ (<?= $cart_count ?>)</h3>
                                <button type="submit" name="update_cart" class="btn btn-light btn-sm">
                                    <i class="bi bi-arrow-repeat me-2"></i>Cập nhật
                                </button>
                            </div>
                            <div class="cart-items">
                                <?php foreach ($cart_items as $item):
                                    $p = $item['product']; $qty = $item['quantity'];
                                    $img_src = !empty($p['image']) 
                                        ? '../../../admin/assets/images/uploads/' . $p['image'] 
                                        : 'https://via.placeholder.com/110x110/f8fafc/94a3b8?text=ShopNets';
                                ?>
                                <div class="cart-item">
                                    <!-- ẢNH SẢN PHẨM ĐÃ CÓ -->
                                    <div class="item-image">
                                        <img src="<?= $img_src ?>" alt="<?= htmlspecialchars($p['name']) ?>">
                                    </div>

                                    <div class="item-details">
                                        <h5 class="item-name"><?= htmlspecialchars($p['name']) ?></h5>
                                        <div class="item-category"><?= htmlspecialchars($p['category_name'] ?? 'Chưa phân loại') ?></div>
                                        <div class="item-price"><?= number_format($p['price'],0,',','.') ?>đ</div>
                                    </div>

                                    <div class="d-flex align-items-center gap-3">
                                        <div class="quantity-control">
                                            <button type="button" class="quantity-btn" onclick="decreaseQuantity(<?= $p['id'] ?>)">-</button>
                                            <input type="number" name="quantity[<?= $p['id'] ?>]" value="<?= $qty ?>" min="1" class="quantity-input" id="quantity-<?= $p['id'] ?>">
                                            <button type="button" class="quantity-btn" onclick="increaseQuantity(<?= $p['id'] ?>)">+</button>
                                        </div>
                                        <button type="submit" name="remove_item" value="<?= $p['id'] ?>" class="remove-btn" 
                                                onclick="return confirm('Xóa sản phẩm này khỏi giỏ hàng?')">
                                            <i class="bi bi-trash-fill"></i>
                                        </button>
                                    </div>
                                </div>
                                <?php endforeach; ?>
                            </div>
                        </div>
                    </div>

                    <div class="col-lg-4">
                        <div class="cart-summary">
                            <h4 class="summary-title">Tóm tắt đơn hàng</h4>
                            <?php 
                            $shipping = $cart_total >= 2000000 ? 0 : 30000; 
                            $total = $cart_total + $shipping; 
                            ?>
                            <div class="summary-row"><span>Tạm tính</span><span><?= number_format($cart_total,0,',','.') ?>đ</span></div>
                            <div class="summary-row"><span>Phí vận chuyển</span>
                                <span><?= $shipping == 0 ? '<strong class="text-success">Miễn phí</strong>' : number_format($shipping,0,',','.').'đ' ?></span>
                            </div>
                            <div class="summary-total"><span>Tổng cộng</span><span><?= number_format($total,0,',','.') ?>đ</span></div>

                            <?php if (isset($_SESSION['user_id'])): ?>
                                <a href="checkout.php" class="checkout-btn">Tiến hành thanh toán</a>
                            <?php else: ?>
                                <a href="<?= BASE_URL ?>auth/login.php?redirect=checkout" class="checkout-btn">Đăng nhập để thanh toán</a>
                            <?php endif; ?>
                        </div>
                    </div>
                </div>
            </form>
        <?php endif; ?>
    </section>

    <?php if (file_exists('../../includes/footer.php')) include '../../includes/footer.php'; ?>

    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
    <script>
        function increaseQuantity(id) {
            const el = document.getElementById('quantity-' + id);
            el.value = parseInt(el.value) + 1;
        }
        function decreaseQuantity(id) {
            const el = document.getElementById('quantity-' + id);
            if (el.value > 1) el.value = parseInt(el.value) - 1;
        }
        document.querySelectorAll('.quantity-input').forEach(i => {
            i.addEventListener('change', () => {
                if (i.value >= 1) document.getElementById('cart-form').submit();
            });
        });
    </script>
</body>
</html>