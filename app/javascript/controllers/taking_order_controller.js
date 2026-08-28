import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productGrid", "currentOrder", "fieldsContainer", "emptyState", "totalElement", "itemCountElement", "sendButton"]
  static values = { cart: Object, emptyState: String }

  connect() {
    this.emptyStateValue = this.currentOrderTarget.innerHTML
  }

  categoryFilter(event) {
    const categoryButtons = document.querySelectorAll(".orders-category-button")
    const category = event.target.dataset.category
    const products = this.productGridTarget.querySelectorAll(".orders-product-card")

    categoryButtons.forEach((button) => {
      if (button === event.target) {
        button.classList.add("active")
      } else {
        button.classList.remove("active")
      }
    })

    products.forEach((product) => {
      if (category === "all" || product.dataset.category === category) {
        product.hidden = false
      } else {
        product.hidden = true
      }
    })
  }

  addProduct(event) {
    console.log("addProduct method - element: ", event.target)
    const button = event.target.closest(".orders-add-product")

    if (!button) return

    const card = button.closest(".orders-product-card")
    const cartState = this.cartValue
    const productId = card.dataset.productId
    const product = {
      id: productId,
      name: card.dataset.productName,
      price: Number(card.dataset.productPrice),
      quantity: 1
    }

    if (productId in cartState) {
      const existing = cartState[productId]
      existing.quantity += 1
    } else {
      cartState[productId] = product
    }
    
    this.cartValue = cartState
    this.renderCart()
  }

  cartActions(event) {
    const button = event.target.closest("[data-cart-action]")
    if (!button) return

    const cartState = this.cartValue
    const productId = button.dataset.productId
    const action = button.dataset.cartAction
    const product = cartState[productId]

    if (!product) return

    if (action === "increase") {
      product.quantity += 1
    }

    if (action === "decrease") {
      product.quantity -= 1
      if (product.quantity <= 0) delete cartState[productId]
    }

    this.cartValue = cartState
    this.renderCart()
  }

  renderCart() {
    const products = Object.values(this.cartValue)

    if (products.length === 0) {
      this.currentOrderTarget.innerHTML = this.emptyStateValue
      this.totalElementTarget.textContent = "$0"
      this.itemCountElementTarget.textContent = "0"
      this.sendButtonTarget.disabled = true
      this.rebuildFromFields()
      return
    }

    this.currentOrderTarget.innerHTML = ""
    products.forEach((product) => {
      const item = document.createElement("article")
      item.className = "current-order-item"
      item.innerHTML = `
        <div class="current-order-item-info">

          <strong>
            ${this.escapeHtml(product.name)}
          </strong>

          <span>
            ${this.formatCurrency(product.price)}
            each
          </span>

        </div>

        <div class="current-order-item-controls">

          <button
            type="button"
            data-cart-action="decrease"
            data-product-id="${product.id}"
            aria-label="Decrease quantity"
          >
            −
          </button>

          <span>
            ${product.quantity}
          </span>

          <button
            type="button"
            data-cart-action="increase"
            data-product-id="${product.id}"
            aria-label="Increase quantity"
          >
            +
          </button>

        </div>


        <strong class="current-order-item-subtotal">
          ${this.formatCurrency(
            product.price * product.quantity
          )}
        </strong>
      `
      this.currentOrderTarget.appendChild(item)
    })

    const itemCount = products.reduce((total, product) => total + product.quantity, 0)
    const subtotal = products.reduce((total, product) => total + product.price * product.quantity, 0)

    this.itemCountElementTarget.textContent = itemCount
    this.totalElementTarget.textContent = this.formatCurrency(subtotal)
    this.sendButtonTarget.disabled = false

    this.rebuildFromFields()
  }

  rebuildFromFields() {
    this.fieldsContainerTarget.innerHTML = ""
    let index = 0
    Object.values(this.cartValue).forEach((product) => {
      this.fieldsContainerTarget.insertAdjacentHTML(
        "beforeend",
        `
          <input
            type="hidden"
            name="order[order_products_attributes][${index}][product_id]"
            value="${product.id}"
          >

          <input
            type="hidden"
            name="order[order_products_attributes][${index}][quantity]"
            value="${product.quantity}"
          >
        `
      )
      index += 1
    })
  }

  formatCurrency(pesos) {
    return new Intl.NumberFormat(
      "es-CO", { style: "currency", currency: "COP" }
    ).format(pesos)
  }

  escapeHtml(value) {
    const div = document.createElement("div")
    div.textContent = value
    return div.innerHTML
  }
}
