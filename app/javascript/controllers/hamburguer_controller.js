import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click() {
    const mobileMenu = document.getElementById('mobileMenu')
    mobileMenu.classList.toggle('active')
  }
}
