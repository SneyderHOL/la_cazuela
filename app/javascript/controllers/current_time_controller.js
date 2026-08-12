import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["time", "date", "greeting"]

  connect() {
    // Run the clock right away when the component connects
    this.updateClock()

    // Refresh the clock every 30,000 milliseconds (30 second)
    this.timer = setInterval(() => {
      this.updateClock()
    }, 30000)
  }

  disconnect() {
    clearInterval(this.timer)
  }

  updateClock() {
    const now = new Date()

    // Format day and month style like "Friday, August 7"
    const dateOptions = { weekday: 'long', month: 'long', day: 'numeric' }
    const dateString = now.toLocaleDateString('en-US', dateOptions)

    if (this.dateTarget.textContent != dateString) this.dateTarget.textContent = dateString

    const currentHour = now.getHours()
    let greetingText

    if (currentHour < 12) {
        greetingText = "Good morning"
    } else if (currentHour < 18) {
        greetingText = "Good afternoon"
    } else {
        greetingText = "Good evening"
    }

    if (this.greetingTarget.textContent != greetingText) this.greetingTarget.textContent = greetingText

    // Format the time to the user's local timezone (e.g., "11:45:10 AM")
    const timeString = now.toLocaleTimeString(
        "en-US",
        {
          hour: "numeric",
          minute: "2-digit"
        }
      )

    // Update the HTML element target with the formatted time string
    this.timeTarget.textContent = timeString
  }
}