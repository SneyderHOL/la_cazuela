import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  scroll() {
    if(window.scrollY > 20){
        this.element.classList.add('scrolled')
    } else {
        this.element.classList.remove('scrolled')
    }
  }
}
