// ========== Định dạng tiền ==========
function formatPrice(price) {
  return price.toLocaleString("vi-VN") + "₫";
}

// ========== Hiển thị giỏ hàng ==========
function renderCart() {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];
  const cartItems = document.getElementById("cart-items");
  const cartTotal = document.getElementById("cart-total");

  if (cart.length === 0) {
    cartItems.innerHTML = "<p>Giỏ hàng trống!</p>";
    cartTotal.textContent = "";
    return;
  }

  let total = 0;
  cartItems.innerHTML = "";

  cart.forEach((item, index) => {
    const subtotal = item.price * item.quantity;
    total += subtotal;

    cartItems.innerHTML += `
      <div class="cart-item">
        <img src="${item.img}" alt="${item.name}">
        <div class="cart-info">
          <h4>${item.name}</h4>
          <p class="cart-price">${formatPrice(item.price)}</p>
          <div class="cart-quantity">
            <button onclick="updateQuantity(${index}, -1)">-</button>
            <span>${item.quantity}</span>
            <button onclick="updateQuantity(${index}, 1)">+</button>
          </div>
        </div>
        <button class="remove-btn" onclick="removeItem(${index})">
          <i class="bi bi-trash3"></i>
        </button>
      </div>
    `;
  });

  cartTotal.textContent = `Tổng cộng: ${formatPrice(total)}`;
}

// ========== Cập nhật số lượng ==========
function updateQuantity(index, change) {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];
  cart[index].quantity += change;

  if (cart[index].quantity <= 0) {
    cart.splice(index, 1);
  }

  localStorage.setItem("cart", JSON.stringify(cart));
  renderCart();
}

// ========== Xóa 1 sản phẩm ==========
function removeItem(index) {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];
  cart.splice(index, 1);
  localStorage.setItem("cart", JSON.stringify(cart));
  renderCart();
}

// ========== Xóa toàn bộ giỏ ==========
document.getElementById("clear-cart").addEventListener("click", () => {
  if (confirm("Bạn có chắc muốn xóa toàn bộ giỏ hàng không?")) {
    localStorage.removeItem("cart");
    renderCart();
  }
});

// ========== Thanh toán ==========
document.getElementById("checkout").addEventListener("click", () => {
  const cart = JSON.parse(localStorage.getItem("cart")) || [];
  if (cart.length === 0) {
    alert("🛍 Giỏ hàng trống, không thể thanh toán!");
    return;
  }
  alert("🎉 Thanh toán thành công! Cảm ơn bạn đã mua hàng tại ShopNets!");
  localStorage.removeItem("cart");
  renderCart();
});

// ========== Chạy khi tải trang ==========
renderCart();
