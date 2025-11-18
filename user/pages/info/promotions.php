<?php
session_start();
require_once '../../includes/database.php';

$db = (new Database())->getConnection();

// === LẤY 6 SẢN PHẨM GIÁ THẤP NHẤT ĐỂ GIẢ LẬP FLASH SALE ===
$stmt = $db->query("
    SELECT * FROM products 
    WHERE inventory > 0 
    ORDER BY price ASC 
    LIMIT 6
");
$flash_products = $stmt->fetchAll(PDO::FETCH_ASSOC);
?>

<!DOCTYPE html>
<html lang="vi">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Flash Sale - Khuyến mãi HOT - ShopNets</title>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.0/dist/css/bootstrap.min.css" rel="stylesheet">
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap" rel="stylesheet">
    <style>
        :root {
            --primary: #2563eb; --danger: #ef4444; --success: #10b981; --warning: #f59e0b;
            --dark: #1e293b; --light: #f8fafc; --border: #e2e8f0; --radius: 16px;
        }
        body { background: #f1f5f9; font-family: 'Inter', sans-serif; padding-top: 136px; color: #333; }
        .container { max-width: 1200px; }

        /* Welcome Banner */
        .welcome-banner {
            background: linear-gradient(135deg, #f59e0b, #f97316);
            color: white;
            padding: 14px 0;
            text-align: center;
            font-weight: 600;
            position: relative;
            z-index: 999;
        }
        .close-banner { background: none; border: none; color: white; font-size: 1.4rem; cursor: pointer; }

        /* Flash Sale Section */
        .flash-sale-section {
            background: linear-gradient(135deg, #dc2626, #b91c1c);
            color: white;
            border-radius: 20px;
            overflow: hidden;
            margin: 2rem 0;
            box-shadow: 0 20px 40px rgba(220, 38, 38, 0.3);
        }
        .flash-sale-header {
            padding: 3rem 2rem;
            text-align: center;
        }
        .flash-sale-title {
            font-size: 3rem;
            font-weight: 800;
            text-shadow: 0 4px 10px rgba(0,0,0,0.4);
        }
        .countdown-timer {
            display: flex;
            justify-content: center;
            gap: 1.5rem;
            margin: 2rem 0;
            flex-wrap: wrap;
        }
        .countdown-item {
            background: rgba(255,255,255,0.25);
            padding: 1rem 1.5rem;
            border-radius: 16px;
            min-width: 90px;
            backdrop-filter: blur(10px);
        }
        .countdown-number {
            font-size: 2.8rem;
            font-weight: 900;
            display: block;
            line-height: 1;
        }
        .countdown-label { font-size: 0.9rem; opacity: 0.9; }

        .flash-product-card {
            background: white;
            border-radius: 16px;
            overflow: hidden;
            transition: all 0.3s;
            height: 100%;
            box-shadow: 0 8px 25px rgba(0,0,0,0.15);
        }
        .flash-product-card:hover {
            transform: translateY(-12px);
            box-shadow: 0 20px 40px rgba(0,0,0,0.25);
        }
        .flash-product-img {
            height: 200px;
            object-fit: contain;
            background: #f8fafc;
            padding: 10px;
        }
        .flash-discount {
            position: absolute;
            top: 12px;
            left: 12px;
            background: #ef4444;
            color: white;
            padding: 6px 14px;
            border-radius: 30px;
            font-weight: 900;
            font-size: 1rem;
            box-shadow: 0 4px 15px rgba(239,68,68,0.5);
            z-index: 10;
        }

        .referral-section {
            background: linear-gradient(135deg, #10b981, #059669);
            color: white;
            border-radius: 20px;
            padding: 4rem 2rem;
            text-align: center;
            margin: 3rem 0;
            box-shadow: 0 15px 35px rgba(16,185,129,0.3);
        }
        .referral-link {
            background: rgba(255,255,255,0.15);
            padding: 12px 20px;
            border-radius: 12px;
            font-family: monospace;
            font-size: 1.1rem;
            margin: 1rem 0;
            word-break: break-all;
        }
    </style>
</head>
<body>

<?php include '../../includes/header.php'; ?>

<!-- Welcome Banner -->
<div class="welcome-banner" id="welcomeBanner">
    <div class="container d-flex justify-content-center align-items-center gap-3 flex-wrap">
        <span>Chào mừng bạn đến ShopNets! Nhận ngay <strong>50K</strong> khi đăng ký!</span>
        <a href="../../auth/register.php" class="btn btn-light btn-sm">Đăng ký ngay</a>
        <button class="close-banner" onclick="document.getElementById('welcomeBanner').style.display='none'">×</button>
    </div>
</div>

<div class="container">

    <!-- Flash Sale -->
    <section class="flash-sale-section position-relative">
        <div class="flash-sale-header">
            <h2 class="flash-sale-title">
                FLASH SALE SẬP SÀN
            </h2>
            <p class="fs-4">Chỉ hôm nay – Giảm giá cực sốc!</p>

            <div class="countdown-timer" id="countdownTimer">
                <div class="countdown-item">
                    <span class="countdown-number" id="hours">00</span>
                    <span class="countdown-label">Giờ</span>
                </div>
                <div class="countdown-item">
                    <span class="countdown-number" id="minutes">00</span>
                    <span class="countdown-label">Phút</span>
                    </div>
                <div class="countdown-item">
                    <span class="countdown-number" id="seconds">00</span>
                    <span class="countdown-label">Giây</span>
                </div>
            </div>

            <a href="products.php" class="btn btn-warning btn-lg px-5 py-3 fw-bold">
                MUA NGAY TRƯỚC KHI HẾT!
            </a>
        </div>

        <?php if ($flash_products): ?>
        <div class="px-4 pb-5">
            <div class="row g-4">
                <?php foreach ($flash_products as $i => $p): 
                    $image_path = !empty($p['image']) 
                        ? '../../../admin/assets/images/uploads/' . $p['image'] 
                        : 'https://via.placeholder.com/300x300/f8fafc/666666?text=No+Image';
                ?>
                    <div class="col-6 col-md-4 col-lg-2">
                        <a href="product-detail.php?id=<?= $p['id'] ?>" class="text-decoration-none">
                            <div class="flash-product-card position-relative">
                                <div class="flash-discount">
                                    -<?= 20 + ($i * 5) ?>%
                                </div>
                                <img src="<?= $image_path ?>" class="flash-product-img w-100" alt="<?= htmlspecialchars($p['name']) ?>">
                                <div class="p-3 text-center">
                                    <h6 class="mb-2 fw-bold text-dark" style="font-size: 0.9rem; height: 40px; overflow: hidden; display: -webkit-box; -webkit-line-clamp: 2; -webkit-box-orient: vertical;">
                                        <?= htmlspecialchars($p['name']) ?>
                                    </h6>
                                    <div class="text-danger fw-bold fs-5">
                                        <?= number_format($p['price'] * 0.7) ?>đ
                                    </div>
                                    <small class="text-muted text-decoration-line-through">
                                        <?= number_format($p['price']) ?>đ
                                    </small>
                                </div>
                            </div>
                        </a>
                    </div>
                <?php endforeach; ?>
            </div>
        </div>
        <?php else: ?>
            <div class="text-center py-5 text-white">
                <h4>Chưa có sản phẩm trong flash sale</h4>
            </div>
        <?php endif; ?>
    </section>

    <!-- Referral -->
    <section class="referral-section">
        <div class="container">
            <h2 class="display-5 fw-bold mb-3">Rủ bạn – Cùng nhận quà!</h2>
            <p class="fs-4">Mời bạn bè đăng ký – Cả hai nhận ngay <strong>50.000đ</strong>!</p>
            <div class="d-flex justify-content-center gap-4 my-5 flex-wrap">
                <div class="text-center">
                    <div class="step-number bg-white text-success fs-3 fw-bold rounded-circle mx-auto mb-3" style="width:60px;height:60px;display:flex;align-items:center;justify-content:center;">1</div>
                    <p class="fw-bold">Chia sẻ link</p>
                </div>
                <div class="text-center">
                    <div class="step-number bg-white text-success fs-3 fw-bold rounded-circle mx-auto mb-3" style="width:60px;height:60px;display:flex;align-items:center;justify-content:center;">2</div>
                    <p class="fw-bold">Bạn bè đăng ký</p>
                </div>
                <div class="text-center">
                    <div class="step-number bg-white text-success fs-3 fw-bold rounded-circle mx-auto mb-3" style="width:60px;height:60px;display:flex;align-items:center;justify-content:center;">3</div>
                    <p class="fw-bold">Cả hai nhận quà</p>
                </div>
            </div>

            <?php if (isset($_SESSION['user_id'])): ?>
                <div class="text-center">
                    <p>Link giới thiệu của bạn:</p>
                    <div class="referral-link">
                        https://shopnets.local/ref/<?= $_SESSION['user_id'] ?>
                    </div>
                    <button class="btn btn-light btn-lg mt-3" onclick="navigator.clipboard.writeText('https://shopnets.local/ref/<?= $_SESSION['user_id'] ?>').then(()=>alert('Đã sao chép!'))">
                        Sao chép link
                    </button>
                </div>
            <?php else: ?>
                <a href="../auth/login.php" class="btn btn-light btn-lg">Đăng nhập để nhận link giới thiệu</a>
            <?php endif; ?>
        </div>
    </section>

</div>

<?php include '../../includes/footer.php'; ?>

<script>
// Countdown đến 0h ngày mai
const end = new Date();
end.setHours(24, 0, 0, 0);

function updateCountdown() {
    const now = new Date();
    const diff = end - now;
    if (diff <= 0) {
        document.getElementById('countdownTimer').innerHTML = '<div class="text-warning fs-3">ĐÃ KẾT THÚC!</div>';
        return;
    }
    const h = Math.floor(diff / (1000*60*60));
    const m = Math.floor((diff % (1000*60*60)) / (1000*60));
    const s = Math.floor((diff % (1000*60)) / 1000);
    document.getElementById('hours').textContent = h.toString().padStart(2, '0');
    document.getElementById('minutes').textContent = m.toString().padStart(2, '0');
    document.getElementById('seconds').textContent = s.toString().padStart(2, '0');
}
updateCountdown();
setInterval(updateCountdown, 1000);
</script>

</body>
</html>