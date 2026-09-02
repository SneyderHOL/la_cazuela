import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["productGrid", "currentOrder", "fieldsContainer", "totalElement", "itemCountElement", "sendButton", "existingOrder"]
  static values = { emptyState: String, existingOrder: Array, removedProductIds: Array, orderLines: Array }

  /*
   * --------------------------------------------------
   * Initialization
   * --------------------------------------------------
   */
  connect() {
    this.emptyStateValue = this.currentOrderTarget.innerHTML
    if (!this.hasExistingOrderTarget) return

    const cartState = JSON.parse(this.existingOrderTarget.textContent)
    this.existingOrderTarget.remove()

    let orderLinesArray = []
    orderLinesArray = cartState.map((item) => ({
      lineId: this.generateLineId(),
      orderProductId: item.orderProductId || null,
      productId: Number(item.productId),
      name: item.name,
      price: Number(item.price || 0),
      quantity: Number(item.quantity || 1),
      note: item.note || ""
    }))

    this.orderLinesValue = orderLinesArray
    this.renderCart()
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

  /*
   * --------------------------------------------------
   * Product selection
   * --------------------------------------------------
   */
  addProduct(event) {
    const button = event.target.closest("[data-add-product]")

    if (!button) return

    const product = {
      productId: Number(button.dataset.productId),
      name: button.dataset.productName,
      price: Number(button.dataset.productPrice || 0),
    }

    /*
     * A product without a note can be merged with another
     * identical line without a note.
     *
     * A product with a note is always its own line.
     */
    const orderLinesArray = this.orderLinesValue
    const existingLine = orderLinesArray.find((line) => {
      return (line.productId === product.productId && this.normalizeNote(line.note) === "")
    })

    if (existingLine) {
      existingLine.quantity += 1
    } else {
      orderLinesArray.push({
        lineId: this.generateLineId(),
        orderProductId: null,
        productId: product.productId,
        name: product.name,
        price: product.price,
        quantity: 1,
        note: ""
      })
    }
    
    this.orderLinesValue = orderLinesArray
    this.renderCart()
  }

  /*
   * --------------------------------------------------
   * Current order actions
   * --------------------------------------------------
   */
  cartActions(event) {
    const button = event.target.closest("[data-line-action]")
    if (!button) return

    const orderLinesArray = this.orderLinesValue
    const lineId = button.dataset.lineId
    const action = button.dataset.lineAction
    const line = this.findLine(lineId, orderLinesArray)

    if (!line) return

    const deletedProductIds = new Set(this.removedProductIdsValue)
    switch (action) {
      case "increase":
        line.quantity += 1
        this.orderLinesValue = orderLinesArray
        this.renderCart()
        break

      case "decrease":
        if (line.quantity > 1) {
          line.quantity -= 1
          this.orderLinesValue = orderLinesArray
          this.renderCart()
          break
        }
        if (line.orderProductId) {
          deletedProductIds.add(line.orderProductId)
          this.removedProductIdsValue = deletedProductIds
        }

        orderLinesArray = orderLinesArray.filter((item) => item.lineId !== line.lineId)
        this.orderLinesValue = orderLinesArray
        this.renderCart()
        break

      case "remove":
        if (line.orderProductId) {
          deletedProductIds.add(line.orderProductId)
          this.removedProductIdsValue = deletedProductIds
        }

        orderLinesArray = orderLinesArray.filter((item) => item.lineId !== line.lineId)
        this.orderLinesValue = orderLinesArray
        this.renderCart()
        break
    }
  }

  /*
   * --------------------------------------------------
   * Notes
   * --------------------------------------------------
   */
  cartInputs(event) {
    const textarea = event.target.closest("[data-line-note]")

    if (!textarea) return

    const orderLinesArray = this.orderLinesValue
    const lineId = textarea.dataset.lineId
    const line = this.findLine(lineId, orderLinesArray)

    if (!line) return

    line.note = textarea.value
    this.orderLinesValue = orderLinesArray
  }

   /*
   * --------------------------------------------------
   * Rendering
   * --------------------------------------------------
   */
  renderCart() {
    if (this.orderLinesValue.length === 0) {
      this.renderEmptyOrder()
      this.updateSummary()
      this.rebuildFormFields()
      return
    }

    this.currentOrderTarget.innerHTML = this.orderLinesValue.map((line) => this.renderOrderLine(line)).join("")
    this.updateSummary()
    this.sendButtonTarget.disabled = false
    this.rebuildFormFields()
  }

  renderOrderLine(line) {
    const subtotal = line.price * line.quantity
    return `
      <article class="current-order-item" data-line-id=${this.escapeAttribute(line.lineId)}">

        <div class="current-order-item-header">

          <div class="current-order-item-info">

            <h4>${this.escapeHtml(line.name)}</h4>

            <span class="current-order-item-price">
              ${this.formatCurrency(line.price)}
            </span>

          </div>

          <button
            type="button"
            class="current-order-remove"
            data-line-action="remove"
            data-line-id="${this.escapeAttribute(line.lineId)}"
            aria-label="Remove ${this.escapeAttribute(line.name)}"
          >
            Remove
          </button>

        </div>

        <div class="current-order-item-footer">

          <div class="current-order-quantity">

            <button
              type="button"
              data-line-action="decrease"
              data-line-id="${this.escapeAttribute(line.lineId)}"
              aria-label="Decrease quantity"
            >
              −
            </button>

            <span>${line.quantity}</span>

            <button
              type="button"
              data-line-action="increase"
              data-line-id="${this.escapeAttribute(line.lineId)}"
              aria-label="Increase quantity"
            >
              +
            </button>

          </div>

          <strong class="current-order-item-subtotal">
            ${this.formatCurrency(subtotal)}
          </strong>

        </div>

        <div class="current-order-note">

          <label for="note-${this.escapeAttribute(line.lineId)}">
            Special instructions
          </label>

          <textarea
            id="note-${this.escapeAttribute(line.lineId)}"
            data-line-note
            data-line-id="${this.escapeAttribute(line.lineId)}"
            rows="2"
            maxlength="500"
            placeholder="e.g. No onions, extra sauce..."
            data-action="input->taking-order#cartInputs"
          >${this.escapeHtml(line.note || "")}</textarea>

        </div>

      </article>
    `
  }

  renderEmptyOrder() {
    this.currentOrderTarget.innerHTML = this.emptyStateValue
    this.sendButtonTarget.disabled = true
  }

  /*
   * --------------------------------------------------
   * Summary
   * --------------------------------------------------
   */
  updateSummary() {
    const itemCount = this.orderLinesValue.reduce(
      (total, line) => total + line.quantity,
      0
    );

    const subtotal = this.orderLinesValue.reduce(
      (total, line) => total + line.price * line.quantity,
      0
    );

    if (this.hasItemCountElementTarget) this.itemCountElementTarget.textContent = itemCount

    if (this.hasTotalElementTarget) this.totalElementTarget.textContent = this.formatCurrency(subtotal)
  }

  /*
   * --------------------------------------------------
   * Rails nested attributes
   * --------------------------------------------------
   */
  rebuildFormFields() {
    this.fieldsContainerTarget.innerHTML = ""
    this.orderLinesValue.forEach((line, index) => {
      this.appendHiddenField(
        `order[order_products_attributes][${index}][product_id]`,
        line.productId
      )

      this.appendHiddenField(
        `order[order_products_attributes][${index}][quantity]`,
        line.quantity
      )

      this.appendHiddenField(
        `order[order_products_attributes][${index}][note]`,
        line.note
      )

      /*
       * Existing database record
       */
      if (line.orderProductId) {
        this.appendHiddenField(
          `order[order_products_attributes][${index}][id]`,
          line.orderProductId
        )
      }
    })
    this.removedProductIdsValue.forEach((orderProductId, index) => {
      const fieldIndex = this.orderLinesValue.length + index

      this.appendHiddenField(
        `order[order_products_attributes][${fieldIndex}][id]`,
        orderProductId
      )

      this.appendHiddenField(
        `order[order_products_attributes][${fieldIndex}][_destroy]`,
        "1"
      )
    })
  }

  appendHiddenField(name, value) {
    const input = document.createElement("input")
    input.type = "hidden"
    input.name = name
    input.value = value ?? ""
    this.fieldsContainerTarget.appendChild(input)
  }

  findLine(lineId, orderLiners) {
    return orderLiners.find((line) => line.lineId === lineId)
  }

  generateLineId() {
    return `line-${Date.now()}-${Math.random().toString(36).substring(2, 8)}`
  }

  normalizeNote(note) {
    return (note || "").trim()
  }

  formatCurrency(pesos) {
    return new Intl.NumberFormat(
      "es-CO", { style: "currency", currency: "COP" }
    ).format(pesos)
  }

  escapeHtml(value) {
    return String(value ?? "")
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;")
      .replace(/'/g, "&#039;")
  }

  escapeAttribute(value) {
    return this.escapeHtml(value)
  }
}
