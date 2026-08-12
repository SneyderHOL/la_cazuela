import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click() {
    const mobileMenuButton = document.getElementById("mobileMenuButton")
    const dashboardSidebar = document.getElementById("dashboardSidebar")
    const sidebarBackdrop = document.getElementById("sidebarBackdrop")

    dashboardSidebar.classList.remove("open")
    sidebarBackdrop.classList.remove("active")
    mobileMenuButton.setAttribute(
      "aria-expanded",
      "false"
    )
  }
}
