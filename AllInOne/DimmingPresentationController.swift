import UIKit

class DimmingPresentationController: UIPresentationController {
  override func shouldRemovePresentersView() -> Bool {
    return false
  }
}
