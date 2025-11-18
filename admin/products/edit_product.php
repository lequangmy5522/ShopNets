<?php

require_once __DIR__ . '/../includes/db_connect.php';

$isAjax = !empty($_SERVER['HTTP_X_REQUESTED_WITH']) && 
          strtolower($_SERVER['HTTP_X_REQUESTED_WITH']) == 'xmlhttprequest';

if ($_SERVER['REQUEST_METHOD'] === 'GET' && $isAjax) {
    $id = isset($_GET['id']) ? (int)$_GET['id'] : 0;
    
    if ($id <= 0) {
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Invalid product ID']);
        exit;
    }

    try {
        $stmt = $pdo->prepare('SELECT * FROM products WHERE id = :id LIMIT 1');
        $stmt->execute([':id' => $id]);
        $product = $stmt->fetch(PDO::FETCH_ASSOC);
        
        if ($product) {
            header('Content-Type: application/json');
            echo json_encode(['success' => true, 'data' => $product]);
            exit;
        } else {
            header('Content-Type: application/json');
            echo json_encode(['success' => false, 'error' => 'Product not found']);
            exit;
        }
    } catch (Exception $e) {
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'error' => 'Database error: ' . $e->getMessage()]);
        exit;
    }
}

$errors = [];
$id = isset($_POST['id']) ? (int)$_POST['id'] : (isset($_GET['id']) ? (int)$_GET['id'] : 0);

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    if ($id <= 0) {
        $errors[] = 'Invalid product ID';
    } else {
        try {
            $stmt = $pdo->prepare('SELECT id FROM products WHERE id = :id LIMIT 1');
            $stmt->execute([':id' => $id]);
            if (!$stmt->fetch()) {
                $errors[] = 'Product not found';
            }
        } catch (Exception $e) {
            $errors[] = 'Database error';
        }

        if (empty($errors)) {
            $name = trim($_POST['name'] ?? '');
            $category = trim($_POST['category'] ?? '');
            $price = $_POST['price'] ?? 0;
            $inventory = $_POST['inventory'] ?? 0;
            $description = trim($_POST['description'] ?? '');
            $imageName = '';
            $oldImage = '';

            try {
                $stmt = $pdo->prepare('SELECT image FROM products WHERE id = :id LIMIT 1');
                $stmt->execute([':id' => $id]);
                $currentProduct = $stmt->fetch(PDO::FETCH_ASSOC);
                $oldImage = $currentProduct['image'] ?? '';
            } catch (Exception $e) {
                $errors[] = 'Failed to get current product data';
            }

            if ($name === '') $errors[] = 'Product name is required';
            if ($category === '') {
                $errors[] = 'Category is required.';
            } else {
                try {
                    $stmt = $pdo->prepare("SELECT id FROM categories WHERE name = :category LIMIT 1");
                    $stmt->execute([':category' => $category]);
                    if (!$stmt->fetch()) {
                        $errors[] = 'Selected category does not exist.';
                    }
                } catch (Exception $e) {
                    $errors[] = 'Error validating category.';
                }
            }
            if (!is_numeric($price)) $errors[] = 'Price must be a number';
            if (!is_numeric($inventory)) $errors[] = 'Inventory must be a number';

            if (isset($_FILES['image']) && $_FILES['image']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = '../assets/images/uploads/';
                
                if (!is_dir($uploadDir)) {
                    mkdir($uploadDir, 0755, true);
                }
                
                $fileInfo = pathinfo($_FILES['image']['name']);
                $extension = strtolower($fileInfo['extension']);
                
                $allowedTypes = ['jpg', 'jpeg', 'png', 'gif'];
                if (!in_array($extension, $allowedTypes)) {
                    $errors[] = 'Invalid image type. Only JPG, PNG, and GIF are allowed.';
                }
                
                if ($_FILES['image']['size'] > 5 * 1024 * 1024) {
                    $errors[] = 'Image size must be less than 5MB.';
                }
                
                if (empty($errors)) {
                    $imageName = 'product_' . time() . '_' . uniqid() . '.' . $extension;
                    $targetPath = $uploadDir . $imageName;
                    
                    if (!move_uploaded_file($_FILES['image']['tmp_name'], $targetPath)) {
                        $errors[] = 'Failed to upload image.';
                        $imageName = '';
                    }
                }
            } else {
                $imageName = $oldImage;
            }

            if (empty($errors)) {
                try {
                    $stmt = $pdo->prepare('UPDATE products SET name = :name, category = :category, price = :price, inventory = :inventory, description = :description, image = :image WHERE id = :id');
                    $stmt->execute([
                        ':name' => $name,
                        ':category' => $category,
                        ':price' => $price,
                        ':inventory' => $inventory,
                        ':description' => $description,
                        ':image' => $imageName,
                        ':id' => $id
                    ]);
                    
                    if ($imageName !== $oldImage && $oldImage && file_exists($uploadDir . $oldImage)) {
                        unlink($uploadDir . $oldImage);
                    }
                    
                    if ($isAjax) {
                        header('Content-Type: application/json');
                        echo json_encode(['success' => true, 'message' => 'Product updated successfully']);
                        exit;
                    } else {
                        header('Location: index.php?msg=' . urlencode('Product updated successfully'));
                        exit;
                    }
                } catch (Exception $e) {
                    if ($imageName !== $oldImage && $imageName && file_exists($uploadDir . $imageName)) {
                        unlink($uploadDir . $imageName);
                    }
                    $errors[] = 'DB error: ' . $e->getMessage();
                }
            } else {
                if ($imageName !== $oldImage && $imageName && file_exists($uploadDir . $imageName)) {
                    unlink($uploadDir . $imageName);
                }
            }
        }
    }

    if ($isAjax) {
        header('Content-Type: application/json');
        echo json_encode(['success' => false, 'errors' => $errors]);
        exit;
    }
}

if (!$isAjax) {
    header('Location: index.php');
    exit;
}
?>
