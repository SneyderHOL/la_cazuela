import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["input", "submit"]

  connect() {
    this.readSelectedValue()
  }

  update(event) {
    // event.target points exactly to the changed radio button
    const selectedValue = event.target.value

    this.enableInput(selectedValue)
  }

  input_update(event) {
    // event.target points exactly to the input in cash-pay
    const text = event.target.value

    this.enableSubmit(Number(text))
  }

  readSelectedValue() {
    const checkedRadio = this.element.querySelector('input[type="radio"]:checked')

    if (checkedRadio) {
      this.enableInput(checkedRadio.value)
    } else {
      this.enableInput(null)
    }
  }

  enableInput(value) {
    if (value === null) {
      this.inputTarget.setAttribute("disabled", "true")
    } else if (value === "transfer" || value === "card") {
      this.inputTarget.setAttribute("disabled", "true")
      this.enableSubmit(value)
    } else {
      this.inputTarget.removeAttribute("disabled")
      this.enableSubmit(null)
    }
  }

  enableSubmit(value) {
    if (value) {
      this.submitTarget.removeAttribute("disabled")
    } else {
      this.submitTarget.setAttribute("disabled", "true")
    }
  }
}
