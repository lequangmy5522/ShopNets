<?php
session_start();
require_once '../../includes/database.php';

if (!isset($_SESSION['user_id'])) {
    header('Location: ../../auth/login.php');
    exit;
}

$db = (new Database())->getConnection();
$user_id = $_SESSION['user_id'];

// LẤY THÔNG TIN USER
$stmt = $db->prepare("SELECT * FROM users WHERE id = ? LIMIT 1");
$stmt->execute([$user_id]);
$user = $stmt->fetch(PDO::FETCH_ASSOC);

if (!$user) {
    session_destroy();
    header('Location: ../../auth/login.php');
    exit;
}

$update_success = false;
$update_error = '';

// CẬP NHẬT HỒ SƠ
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['update_profile'])) {
    $full_name = trim($_POST['full_name'] ?? '');
    $email     = trim($_POST['email'] ?? '');
    $phone     = trim($_POST['phone'] ?? '');
    $address   = trim($_POST['address'] ?? '');

    if (empty($full_name) || empty($email)) {
        $update_error = 'Vui lòng điền đầy đủ họ tên và email.';
    } else {
        $check = $db->prepare("SELECT id FROM users WHERE email = ? AND id != ?");
        $check->execute([$email, $user_id]);
        if ($check->fetch()) {
            $update_error = 'Email này đã được sử dụng.';
        } else {
            $sql = "UPDATE users SET full_name = ?, email = ?, phone = ?, address = ? WHERE id = ?";
            $stmt = $db->prepare($sql);
            $stmt->execute([$full_name, $email, $phone, $address, $user_id]);

            $_SESSION['full_name'] = $full_name;
            $user['full_name'] = $full_name;
            $user['email'] = $email;
            $user['phone'] = $phone;
            $user['address'] = $address;

            $update_success = true;
        }
    }
}

// ĐỔI MẬT KHẨU
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['change_password'])) {
    $current = $_POST['current_password'] ?? '';
    $new     = $_POST['new_password'] ?? '';
    $confirm = $_POST['confirm_password'] ?? '';

    if (empty($current) || empty($new) || empty($confirm)) {
        $update_error = 'Vui lòng điền đầy đủ thông tin.';
    } elseif ($new !== $confirm) {
        $update_error = 'Mật khẩu xác nhận không khớp.';
    } elseif (!password_verify($current, $user['password'])) {
        $update_error = 'Mật khẩu hiện tại không đúng.';
    } elseif (strlen($new) < 6) {
        $update_error = 'Mật khẩu mới phải có ít nhất 6 ký tự.';
    } else {
        $hashed = password_hash($new, PASSWORD_DEFAULT);
        $stmt = $db->prepare("UPDATE users SET password = ? WHERE id = ?");
        $stmt->execute([$hashed, $user_id]);
        $update_success = true;
    }
}
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Hồ sơ cá nhân - ShopNets</title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root { --primary: #2563eb; --danger: #ef4444; --success: #10b981; --radius: 16px; }
        body { background: #f8fafc; font-family: 'Inter', sans-serif; padding-top: 136px; color: #333; }
        .container { max-width: 1100px; }
        .profile-header { background: white; border-radius: var(--radius); padding: 2.5rem; box-shadow: 0 4px 20px rgba(0,0,0,0.1); margin-bottom: 2rem; display: flex; align-items: center; gap: 2rem; }
        .avatar { width: 120px; height: 120px; background: var(--primary); color: white; border-radius: 50%; display: flex; align-items: center; justify-content: center; font-size: 3.5rem; font-weight: bold; }
        .nav-tabs .nav-link { font-size: 1.6rem; padding: 1rem 2rem; border: none; color: #666; }
        .nav-tabs .nav-link.active { color: var(--primary); border-bottom: 4px solid var(--primary); border-radius: 0; }
        .profile-content { background: white; border-radius: var(--radius); padding: 2.5rem; box-shadow: 0 4px 20px rgba(0,0,0,0.1); margin-bottom: 2rem; }
        .form-control { font-size: 1.5rem; padding: 1rem 1.5rem; border-radius: 12px; }
        .btn-primary { background: var(--primary); border: none; padding: 1rem 2.5rem; border-radius: 50px; font-weight: 600; font-size: 1.5rem; }
        .alert { border-radius: 12px; font-size: 1.5rem; margin-bottom: 1.5rem; }
        .empty-state { text-align: center; padding: 5rem 2rem; color: #888; }
        .empty-state i { font-size: 5rem; color: #ccc; margin-bottom: 1rem; }
        .badge { font-size: 1.3rem; padding: 0.5em 1em; }
    </style>
</head>
<body>

<?php include '../../includes/header.php'; ?>

<div class="container">

    <!-- Header hồ sơ -->
    <div class="profile-header">
        <div class="avatar">
            <?= strtoupper(substr($user['full_name'] ?? $user['username'], 0, 2)) ?>
        </div>
        <div>
            <h2><?= htmlspecialchars($user['full_name'] ?? $user['username']) ?></h2>
            <p><i class="bi bi-envelope"></i> <?= htmlspecialchars($user['email']) ?></p>
            <p><i class="bi bi-person"></i> <?= htmlspecialchars($user['username']) ?></p>
        </div>
    </div>

    <!-- Tabs -->
    <ul class="nav nav-tabs mb-4">
        <li class="nav-item"><a class="nav-link active" data-bs-toggle="tab" href="#profile">Thông tin cá nhân</a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#password">Đổi mật khẩu</a></li>
        <li class="nav-item"><a class="nav-link" data-bs-toggle="tab" href="#orders">Đơn hàng của tôi</a></li>
    </ul>

    <div class="tab-content">

        <!-- Thông tin cá nhân -->
        <div class="tab-pane fade show active profile-content" id="profile">
            <h3>Cập nhật thông tin</h3>
            <?php if ($update_success && isset($_POST['update_profile'])): ?>
                <div class="alert alert-success">Cập nhật thông tin thành công!</div>
            <?php endif; ?>
            <?php if ($update_error && isset($_POST['update_profile'])): ?>
                <div class="alert alert-danger"><?= htmlspecialchars($update_error) ?></div>
            <?php endif; ?>

            <form method="POST">
                <div class="row g-4">
                    <div class="col-md-6">
                        <label class="form-label">Họ và tên *</label>
                        <input type="text" name="full_name" class="form-control" value="<?= htmlspecialchars($user['full_name'] ?? '') ?>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Email *</label>
                        <input type="email" name="email" class="form-control" value="<?= htmlspecialchars($user['email'] ?? '') ?>" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Số điện thoại</label>
                        <input type="text" name="phone" class="form-control" value="<?= htmlspecialchars($user['phone'] ?? '') ?>">
                    </div>
                    <div class="col-12">
                        <label class="form-label">Địa chỉ</label>
                        <textarea name="address" class="form-control" rows="3"><?= htmlspecialchars($user['address'] ?? '') ?></textarea>
                    </div>
                </div>
                <div class="mt-4">
                    <button type="submit" name="update_profile" class="btn btn-primary">Lưu thay đổi</button>
                </div>
            </form>
        </div>

        <!-- Đổi mật khẩu -->
        <div class="tab-pane fade profile-content" id="password">
            <h3>Đổi mật khẩu</h3>
            <?php if ($update_success && isset($_POST['change_password'])): ?>
                <div class="alert alert-success">Đổi mật khẩu thành công!</div>
            <?php endif; ?>
            <?php if ($update_error && isset($_POST['change_password'])): ?>
                <div class="alert alert-danger"><?= htmlspecialchars($update_error) ?></div>
            <?php endif; ?>

            <form method="POST">
                <div class="row g-4">
                    <div class="col-md-6">
                        <label class="form-label">Mật khẩu hiện tại *</label>
                        <input type="password" name="current_password" class="form-control" required>
                    </div>
                </div>
                <div class="row g-4 mt-3">
                    <div class="col-md-6">
                        <label class="form-label">Mật khẩu mới *</label>
                        <input type="password" name="new_password" class="form-control" required>
                    </div>
                    <div class="col-md-6">
                        <label class="form-label">Xác nhận mật khẩu mới *</label>
                        <input type="password" name="confirm_password" class="form-control" required>
                    </div>
                </div>
                <div class="mt-4">
                    <button type="submit" name="change_password" class="btn btn-primary">Đổi mật khẩu</button>
                </div>
            </form>
        </div>

        <!-- ĐƠN HÀNG CỦA TÔI - CHUYỂN SANG TRANG RIÊNG -->
        <div class="tab-pane fade profile-content" id="orders">
            <h3>Đơn hàng của tôi</h3>

            <?php
            $sql = "SELECT o.*, COUNT(oi.id) as total_items
                    FROM orders o
                    LEFT JOIN order_items oi ON o.id = oi.order_id
                    WHERE o.user_id = ?
                    GROUP BY o.id
                    ORDER BY o.created_at DESC";

            $stmt = $db->prepare($sql);
            $stmt->execute([$user_id]);
            $orders = $stmt->fetchAll(PDO::FETCH_ASSOC);
            ?>

            <?php if (empty($orders)): ?>
                <div class="empty-state">
                    <i class="bi bi-bag"></i>
                    <h4>Chưa có đơn hàng nào</h4>
                    <p>Khi bạn đặt hàng, chúng sẽ xuất hiện tại đây.</p>
                    <a href="<?= BASE_URL ?>index.php" class="btn btn-primary mt-3">Tiếp tục mua sắm</a>
                </div>
            <?php else: ?>
                <div class="table-responsive">
                    <table class="table table-hover align-middle">
                        <thead class="table-light">
                            <tr>
                                <th>Mã đơn hàng</th>
                                <th>Ngày đặt</th>
                                <th>Sản phẩm</th>
                                <th>Tổng tiền</th>
                                <th>Trạng thái</th>
                                <th>Thanh toán</th>
                                <th></th>
                            </tr>
                        </thead>
                        <tbody>
                            <?php foreach ($orders as $order): ?>
                                <tr>
                                    <td><strong>#<?= htmlspecialchars($order['order_number']) ?></strong></td>
                                    <td><?= date('d/m/Y H:i', strtotime($order['created_at'])) ?></td>
                                    <td><?= $order['total_items'] ?> sản phẩm</td>
                                    <td><strong class="text-primary"><?= number_format($order['total_amount'], 0, ',', '.') ?>đ</strong></td>
                                    <td>
                                        <?php
                                        $statusMap = [
                                            'pending' => ['warning', 'Chờ xác nhận'],
                                            'confirmed' => ['info', 'Đã xác nhận'],
                                            'processing' => ['primary', 'Đang xử lý'],
                                            'shipped' => ['secondary', 'Đã giao'],
                                            'delivered' => ['success', 'Hoàn thành'],
                                            'cancelled' => ['danger', 'Đã hủy']
                                        ];
                                        $info = $statusMap[$order['order_status']] ?? ['secondary', ucfirst($order['order_status'])];
                                        ?>
                                        <span class="badge bg-<?= $info[0] ?>"><?= $info[1] ?></span>
                                    </td>
                                    <td>
                                        <span class="badge bg-<?= $order['payment_status'] === 'paid' ? 'success' : 'danger' ?>">
                                            <?= $order['payment_status'] === 'paid' ? 'Đã thanh toán' : 'Chưa thanh toán' ?>
                                        </span>
                                    </td>
                                    <td>
                                        <a href="order-detail.php?id=<?= $order['id'] ?>" class="btn btn-sm btn-outline-primary">
                                            Xem chi tiết
                                        </a>
                                    </td>
                                </tr>
                            <?php endforeach; ?>
                        </tbody>
                    </table>
                </div>
            <?php endif; ?>
        </div>

    </div>
</div>

<?php include '../../includes/footer.php'; ?>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>