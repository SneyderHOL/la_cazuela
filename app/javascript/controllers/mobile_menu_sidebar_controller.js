import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  click() {
    const dashboardSidebar = document.getElementById("dashboardSidebar")
    const sidebarBackdrop = document.getElementById("sidebarBackdrop")
    const isOpen = dashboardSidebar.classList.contains("open")

    if (isOpen) {
      dashboardSidebar.classList.remove("open")
      sidebarBackdrop.classList.remove("active")
      this.element.setAttribute(
        "aria-expanded",
        "false"
      )
    } else {
      dashboardSidebar.classList.add("open")
      sidebarBackdrop.classList.add("active")
      this.element.setAttribute(
        "aria-expanded",
        "true"
      )
    }
  }
}
