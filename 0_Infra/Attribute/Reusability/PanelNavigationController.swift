import UIKit
import FloatingPanel

class PanelNavigationController: UINavigationController, PanelContent {
    var allowsEditing = true
    
    var panelContentDelegate: PanelContentDelegate!
    
    let showBackBtn = true
    
    var prevPanelState: FloatingPanelState?
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .full, animated: false)
        }
        super.viewDidAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let prevPanelState = prevPanelState {
            UIView.animate(withDuration: 0.25) {
                self.panelContentDelegate.panel.move(to: prevPanelState, animated: false)
            }
        }
        super.viewWillDisappear(animated)
    }
}
