<?php
session_start();
require_once '../../includes/database.php';

if (!isset($_SESSION['user_id'])) {
    header('Location: ../../auth/login.php');
    exit;
}

if (!isset($_GET['id']) || !is_numeric($_GET['id'])) {
    header('Location: profile.php');
    exit;
}

$order_id = (int)$_GET['id'];
$user_id = $_SESSION['user_id'];
$db = (new Database())->getConnection();

// LẤY ĐƠN HÀNG
$stmt = $db->prepare("SELECT o.* FROM orders o WHERE o.id = ? AND o.user_id = ? LIMIT 1");
$stmt->execute([$order_id, $user_id]);
$order = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$order) {
    die('<div class="container mt-5"><div class="alert alert-danger text-center p-4">Đơn hàng không tồn tại hoặc bạn không có quyền xem!</div></div>');
}

// LẤY SẢN PHẨM TRONG ĐƠN + JOIN ĐỂ LẤY ẢNH TỪ BẢNG PRODUCTS
$items_stmt = $db->prepare("
    SELECT oi.*, p.image 
    FROM order_items oi 
    LEFT JOIN products p ON oi.product_id = p.id 
    WHERE oi.order_id = ? 
    ORDER BY oi.id
");
$items_stmt->execute([$order_id]);
$order_items = $items_stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Chi tiết đơn hàng #<?= htmlspecialchars($order['order_number']) ?> - ShopNets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb;
            --primary-dark: #1d4ed8;
            --danger: #ef4444;
            --success: #10b981;
            --radius: 16px;
        }
        body {
            background: #f1f5f9;
            font-family: 'Inter', sans-serif;
            padding-top: 136px;
            color: #1e293b;
        }
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
        .container { max-width: 1100px; }

        .order-header {
            background: linear-gradient(135deg, var(--primary), var(--primary-dark));
            color: white;
            padding: 2rem;
            border-radius: var(--radius) var(--radius) 0 0;
        }

        .status-badge {
            padding: 0.6rem 1.4rem;
            border-radius: 50px;
            font-weight: 600;
            font-size: 1.4rem;
        }
        .status-pending    { background: #fffbeb; color: #92400e; }
        .status-confirmed  { background: #dbeafe; color: #1e40af; }
        .status-processing { background: #cffafe; color: #0e7490; }
        .status-shipped    { background: #d1fae5; color: #065f46; }
        .status-delivered  { background: #ecfdf5; color: #065f46; }
        .status-cancelled  { background: #fee2e2; color: #991b1b; }

        .order-card {
            background: white;
            border-radius: var(--radius);
            box-shadow: 0 10px 30px rgba(0,0,0,0.08);
            overflow: hidden;
            margin-bottom: 3rem;
        }

        .product-item {
            border-bottom: 1px solid #e2e8f0;
            padding: 1.5rem 0;
            display: flex;
            align-items: center;
            gap: 1.5rem;
        }
        .product-item:last-child { border-bottom: none; }

        .product-img {
            width: 90px;
            height: 90px;
            object-fit: cover;
            border-radius: 12px;
            border: 1px solid #e2e8f0;
            background: #fff;
        }

        .breadcrumb {
            background: white;
            padding: 1rem 1.5rem;
            border-radius: var(--radius);
            box-shadow: 0 2px 10px rgba(0,0,0,0.05);
        }
    </style>
</head>
<body>

<?php include '../../includes/header.php'; ?>

<div class="container mt-4">
    <nav aria-label="breadcrumb">
        <ol class="breadcrumb">
            <li class="breadcrumb-item"><a href="<?= BASE_URL ?>index.php">Trang chủ</a></li>
            <li class="breadcrumb-item"><a href="profile.php">Hồ sơ cá nhân</a></li>
            <li class="breadcrumb-item active" aria-current="page">
                Đơn hàng #<?= htmlspecialchars($order['order_number']) ?>
            </li>
        </ol>
    </nav>


    <div class="order-card">

        <div class="order-header">
            <div class="d-flex justify-content-between align-items-center flex-wrap gap-3">
                <div>
                    <h2 class="mb-1 fw-bold">Đơn hàng #<?= htmlspecialchars($order['order_number']) ?></h2>
                    <p class="mb-0 opacity-90">Ngày đặt: <?= date('d/m/Y H:i', strtotime($order['created_at'])) ?></p>
                </div>
                <span class="status-badge status-<?= $order['order_status'] ?>">
                    <?php
                    $statusText = [
                        'pending'    => 'Chờ xác nhận',
                        'confirmed'  => 'Đã xác nhận',
                        'processing' => 'Đang xử lý',
                        'shipped'    => 'Đang giao',
                        'delivered'  => 'Đã giao',
                        'cancelled'  => 'Đã hủy'
                    ];
                    echo $statusText[$order['order_status']] ?? ucfirst($order['order_status']);
                    ?>
                </span>
            </div>
        </div>

        <div class="p-4 p-lg-5">

            <div class="row mb-5">
                <div class="col-md-6">
                    <h5 class="fw-bold mb-3">Thông tin giao hàng</h5>
                    <p class="mb-1"><strong><?= htmlspecialchars($order['customer_name']) ?></strong></p>
                    <p class="mb-1"><?= htmlspecialchars($order['customer_phone'] ?? 'Chưa cung cấp') ?></p>
                    <p class="mb-0 text-muted"><?= nl2br(htmlspecialchars($order['shipping_address'])) ?></p>
                </div>
                <div class="col-md-6 text-md-end">
                    <h5 class="fw-bold mb-3">Thanh toán</h5>
                    <p class="mb-2">
                        <?php
                        $payMethod = [
                            'cod' => 'Thanh toán khi nhận hàng (COD)',
                            'bank_transfer' => 'Chuyển khoản ngân hàng',
                            'momo' => 'Ví MoMo',
                            'vnpay' => 'VNPay'
                        ];
                        echo $payMethod[$order['payment_method']] ?? strtoupper($order['payment_method']);
                        ?>
                    </p>
                    <span class="badge fs-6 bg-<?= $order['payment_status'] === 'paid' ? 'success' : 'danger' ?>">
                        <?= $order['payment_status'] === 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán' ?>
                    </span>
                </div>
            </div>

            <h5 class="fw-bold border-bottom pb-3 mb-4">Sản phẩm trong đơn hàng</h5>
            <div class="bg-light rounded-3 p-4">
                <?php foreach ($order_items as $item): 
                    $image_path = !empty($item['image']) 
                        ? '../../../admin/assets/images/uploads/' . $item['image'] 
                        : 'https://via.placeholder.com/90x90/eeeeee/999999?text=No+Image';
                ?>
                    <div class="product-item">
                        <img src="<?= $image_path ?>" alt="<?= htmlspecialchars($item['product_name']) ?>" class="product-img">
                        <div class="flex-fill">
                            <h6 class="mb-1 fw-semibold"><?= htmlspecialchars($item['product_name']) ?></h6>
                            <small class="text-muted">Số lượng: <?= $item['quantity'] ?></small>
                        </div>
                        <strong class="text-danger fs-5">
                            <?= number_format($item['total_price'], 0, ',', '.') ?>đ
                        </strong>
                    </div>
                <?php endforeach; ?>

                <hr class="my-4">
                <div class="d-flex justify-content-between align-items-center fw-bold fs-4">
                    <span>Tổng cộng:</span>
                    <span class="text-primary"><?= number_format($order['total_amount'], 0, ',', '.') ?>đ</span>
                </div>
            </div>

            <div class="text-end mt-4">
                <a href="profile.php#orders" class="btn btn-outline-primary btn-lg px-5">
                    Quay lại đơn hàng
                </a>
            </div>
        </div>
    </div>
</div>

<?php include '../../includes/footer.php'; ?>
<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>