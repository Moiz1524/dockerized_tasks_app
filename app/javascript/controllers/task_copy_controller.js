import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["button", "label"]
  static values = { title: String, description: String }

  copy() {
    const lines = [this.titleValue]
    if (this.descriptionValue.trim()) {
      lines.push(this.descriptionValue.trim())
    }
    const text = lines.join("\n\n")

    navigator.clipboard.writeText(text).then(() => {
      this.labelTarget.textContent = "Copied!"
      this.buttonTarget.classList.add("text-indigo-600", "border-indigo-300", "bg-indigo-50")
      this.buttonTarget.classList.remove("text-gray-500", "border-gray-200", "bg-gray-50")

      setTimeout(() => {
        this.labelTarget.textContent = "Copy"
        this.buttonTarget.classList.remove("text-indigo-600", "border-indigo-300", "bg-indigo-50")
        this.buttonTarget.classList.add("text-gray-500", "border-gray-200", "bg-gray-50")
      }, 2000)
    })
  }
}
