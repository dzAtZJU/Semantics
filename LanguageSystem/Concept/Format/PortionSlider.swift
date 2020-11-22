import UIKit

class PortionSlider: UIView {
    
    private let label = UILabel()
    
    private(set) var portion: Int! {
        didSet {
            label.text = "\(portion!)%"
        }
    }
    
    init() {
        super.init(frame: .zero)
        
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 100
        slider.addTarget(self, action: #selector(slided), for: .valueChanged)
        
        let stack = UIStackView(arrangedSubviews: [label, slider])
        stack.axis = .horizontal
        addSubview(stack)
        stack.fillToSuperview()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func slided(sender: UIControl) {
        portion = Int((sender as! UISlider).value)
    }
}
