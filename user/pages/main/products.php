<?php
session_start();
require_once '../../includes/database.php';
require_once '../../includes/functions.php';

$db = (new Database())->getConnection();

// === FIX LỖI: KHAI BÁO BIẾN TỪ ĐẦU ===
$search   = trim($_GET['search'] ?? '');
$category = $_GET['category'] ?? '';
$page     = max(1, (int)($_GET['page'] ?? 1));
$limit    = 12;
$offset   = ($page - 1) * $limit;

// Xây dựng truy vấn
$sql = "SELECT * FROM products WHERE 1=1";
$params = [];

if ($category) {
    $sql .= " AND category = ?";
    $params[] = $category;
}
if ($search !== '') {
    $sql .= " AND name LIKE ?";
    $params[] = "%$search%";
}

$sql .= " ORDER BY created_at DESC LIMIT $limit OFFSET $offset";

$stmt = $db->prepare($sql);
$stmt->execute($params);
$products = $stmt->fetchAll(PDO::FETCH_ASSOC);

// Đếm tổng
$count_sql = "SELECT COUNT(*) FROM products WHERE 1=1";
$count_params = [];
if ($category) {
    $count_sql .= " AND category = ?";
    $count_params[] = $category;
}
if ($search !== '') {
    $count_sql .= " AND name LIKE ?";
    $count_params[] = "%$search%";
}
$count_stmt = $db->prepare($count_sql);
$count_stmt->execute($count_params);
$total_products = $count_stmt->fetchColumn();
$total_pages = ceil($total_products / $limit);

// Danh sách danh mục
$cat_stmt = $db->query("SELECT DISTINCT category FROM products ORDER BY category");
$categories = $cat_stmt->fetchAll(PDO::FETCH_COLUMN);
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>
        <?= $search ? htmlspecialchars($search) . ' - Tìm kiếm' : 'Tất cả sản phẩm' ?> - ShopNets
    </title>
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap-icons@1.13.1/font/bootstrap-icons.min.css">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb; --primary-dark: #1d4ed8; --danger: #ef4444; --success: #10b981;
            --gray: #94a3b8; --dark: #1e293b; --light: #f8fafc; --border: #e2e8f0;
            --radius: 16px; --shadow: 0 4px 20px rgba(0,0,0,0.1); --transition: all 0.3s ease;
        }
        body { background: #f1f5f9; font-family: 'Inter', sans-serif; padding-top: 136px; color: #1e293b; }
        .container { max-width: 1200px; }

        /* TIÊU ĐỀ ĐẸP - CHỈ HIỆN KHI CÓ TÌM KIẾM */
        .page-title {
            font-size: 2.8rem; font-weight: 700; text-align: center; margin: 3rem 0 2rem;
            color: var(--dark); position: relative;
        }
        .page-title::after {
            content: ''; position: absolute; bottom: -12px; left: 50%; transform: translateX(-50%);
            width: 80px; height: 5px; background: var(--primary); border-radius: 3px;
        }
        .search-keyword {
            color: var(--primary);
            font-weight: 800;
            padding: 4px 12px;
            background: #dbeafe;
            border-radius: 8px;
        }

        /* THANH LỌC */
        .filter-bar {
            background: white; padding: 28px; border-radius: var(--radius); box-shadow: var(--shadow);
            margin-bottom: 32px; border: 1px solid var(--border);
        }
        .filter-bar .form-control,
        .filter-bar .form-select {
            border-radius: 50px !important; padding: 14px 20px !important; font-size: 1.5rem;
            border: 2px solid #e2e8f0;
        }
        .filter-bar .form-control:focus,
        .filter-bar .form-select:focus {
            border-color: var(--primary); box-shadow: 0 0 0 4px rgba(37, 99, 235, 0.15);
        }
        .filter-bar .btn-search {
            background: var(--primary); color: white; border: none;
            border-radius: 50% !important; width: 56px; height: 56px; font-size: 1.8rem;
            display: flex; align-items: center; justify-content: center;
        }
        .filter-bar .btn-search:hover {
            background: var(--primary-dark); transform: scale(1.1);
        }

        /* CARD SẢN PHẨM - GIỐNG INDEX */
        .product-card {
            background: white; border-radius: var(--radius); overflow: hidden;
            box-shadow: 0 4px 15px rgba(0,0,0,0.08); transition: var(--transition); height: 100%;
            border: 1px solid var(--border); position: relative;
        }
        .product-card:hover {
            transform: translateY(-10px); box-shadow: 0 20px 40px rgba(0,0,0,0.15);
            border-color: var(--primary);
        }
        .product-image {
            position: relative; height: 220px; overflow: hidden; background: #fafafa;
        }
        .product-image img {
            width: 100%; height: 100%; object-fit: contain; transition: transform 0.4s ease;
        }
        .product-card:hover img { transform: scale(1.08); }
        .product-overlay {
            position: absolute; top: 0; left: 0; width: 100%; height: 100%;
            background: rgba(0,0,0,0.5); display: flex; align-items: center; justify-content: center;
            opacity: 0; visibility: hidden; transition: var(--transition);
        }
        .product-card:hover .product-overlay { opacity: 1; visibility: visible; }

        .product-info { padding: 18px; }
        .product-title {
            font-size: 1.5rem; font-weight: 600; color: var(--dark); margin-bottom: 10px;
            height: 52px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;
        }
        .product-price {
            font-size: 1.9rem; font-weight: 700; color: var(--danger); margin-bottom: 14px;
        }
        .product-actions { display: flex; gap: 10px; }
        .btn-custom {
            flex: 1; padding: 12px; border-radius: 12px; font-size: 1.4rem; font-weight: 600;
            text-align: center; transition: var(--transition);
        }
        .btn-add-cart {
            background: transparent; border: 2px solid var(--primary); color: var(--primary);
        }
        .btn-add-cart:hover { background: var(--primary); color: white; }
        .btn-detail { background: var(--primary); color: white; }
        .btn-detail:hover { background: var(--primary-dark); }
        .btn-detail, .product-overlay a { text-decoration: none !important; }

        .no-products { text-align: center; padding: 80px 20px; color: #666; }
        .no-products i { font-size: 6rem; color: #ddd; margin-bottom: 20px; }
    </style>
</head>
<body>

<?php include '../../includes/header.php'; ?>

<div class="container">

    <!-- TIÊU ĐỀ THÔNG MINH -->
    <?php if ($search !== ''): ?>
        <h1 class="page-title">
            Kết quả tìm kiếm cho: <span class="search-keyword"><?= htmlspecialchars($search) ?></span>
            <small class="d-block mt-2 text-muted">Tìm thấy <?= $total_products ?> sản phẩm</small>
        </h1>
    <?php else: ?>
        <h1 class="page-title">Tất cả sản phẩm</h1>
    <?php endif; ?>

    <!-- THANH LỌC -->
    <div class="filter-bar">
        <form method="GET" class="row g-3 align-items-center">
            <div class="col-md-4">
                <select name="category" class="form-select">
                    <option value="">Tất cả danh mục</option>
                    <?php foreach ($categories as $cat): ?>
                        <option value="<?= htmlspecialchars($cat) ?>" <?= $category === $cat ? 'selected' : '' ?>>
                            <?= ucfirst(htmlspecialchars($cat)) ?>
                        </option>
                    <?php endforeach; ?>
                </select>
            </div>
            <div class="col-md-6">
                <input type="text" name="search" class="form-control" 
                       placeholder="Tìm kiếm sản phẩm..." 
                       value="<?= htmlspecialchars($search) ?>">
            </div>
            <div class="col-md-2">
                <button type="submit" class="btn btn-search">
                    <i class="bi bi-search"></i>
                </button>
            </div>
        </form>
    </div>

    <!-- DANH SÁCH SẢN PHẨM -->
    <?php if ($products): ?>
        <div class="row g-4">
            <?php foreach ($products as $p): 
                $image_path = !empty($p['image']) 
                    ? '../../../admin/assets/images/uploads/' . $p['image'] 
                    : 'https://via.placeholder.com/300x300/eeeeee/999999?text=No+Image';
            ?>
                <div class="col-6 col-md-4 col-lg-3">
                    <div class="product-card">
                        <div class="product-image">
                            <img src="<?= $image_path ?>" alt="<?= htmlspecialchars($p['name']) ?>">
                            <div class="product-overlay">
                                <a href="product-detail.php?id=<?= $p['id'] ?>" class="btn btn-light btn-lg">
                                    Xem chi tiết
                                </a>
                            </div>
                        </div>
                        <div class="product-info">
                            <h3 class="product-title"><?= htmlspecialchars($p['name']) ?></h3>
                            <div class="product-price">
                                <?= number_format($p['price'], 0, ',', '.') ?>đ
                            </div>
                            <div class="product-actions">
                                <button class="btn-custom btn-add-cart add-to-cart" data-id="<?= $p['id'] ?>">
                                    Thêm vào giỏ
                                </button>
                                <a href="product-detail.php?id=<?= $p['id'] ?>" class="btn-custom btn-detail">
                                    Chi tiết
                                </a>
                            </div>
                        </div>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <!-- PHÂN TRANG -->
        <?php if ($total_pages > 1): ?>
            <nav class="mt-5">
                <ul class="pagination justify-content-center">
                    <?php if ($page > 1): ?>
                        <li class="page-item"><a class="page-link" href="?page=<?= $page-1 ?>&category=<?= urlencode($category) ?>&search=<?= urlencode($search) ?>">Trước</a></li>
                    <?php endif; ?>
                    <?php for ($i = max(1, $page-2); $i <= min($total_pages, $page+2); $i++): ?>
                        <li class="page-item <?= $i == $page ? 'active' : '' ?>">
                            <a class="page-link" href="?page=<?= $i ?>&category=<?= urlencode($category) ?>&search=<?= urlencode($search) ?>"><?= $i ?></a>
                        </li>
                    <?php endfor; ?>
                    <?php if ($page < $total_pages): ?>
                        <li class="page-item"><a class="page-link" href="?page=<?= $page+1 ?>&category=<?= urlencode($category) ?>&search=<?= urlencode($search) ?>">Sau</a></li>
                    <?php endif; ?>
                </ul>
            </nav>
        <?php endif; ?>

    <?php else: ?>
        <div class="no-products">
            <i class="bi bi-emoji-frown"></i>
            <h3>Không tìm thấy sản phẩm nào</h3>
            <p>Hãy thử tìm với từ khóa khác nhé!</p>
            <a href="products.php" class="btn btn-primary">Quay lại tất cả sản phẩm</a>
        </div>
    <?php endif; ?>
</div>

<?php include '../../includes/footer.php'; ?>

<script src="https://code.jquery.com/jquery-3.6.0.min.js"></script>
<script>
$(document).on('click', '.add-to-cart', function() {
    const id = $(this).data('id');
    <?php if (isset($_SESSION['user_id'])): ?>
        $.post('../../ajax/add_to_cart.php', { product_id: id, quantity: 1 }, function(res) {
            if (res.success) {
                alert('Đã thêm vào giỏ hàng!');
                $('.cart-badge').text(res.cart_count);
            } else {
                alert(res.message || 'Có lỗi xảy ra!');
            }
        }, 'json');
    <?php else: ?>
        alert('Vui lòng đăng nhập để mua hàng!');
        location.href = '../../auth/login.php';
    <?php endif; ?>
});
</script>
</body>
</html>