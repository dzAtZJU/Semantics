import UIKit

class TestVC: UIViewController {
    
    private lazy var junior: UILabel = {
        let tmp = UILabel()
        tmp.text = "junior"
        return tmp
    }()
    
    private lazy var senior: UILabel = {
        let tmp = UILabel()
        tmp.text = "senior"
        return tmp
    }()
    
    private lazy var scrollView: UIScrollView = {
        let tmp = UIScrollView()
        tmp.maximumZoomScale = 2
        tmp.backgroundColor = .systemBackground
        tmp.contentSize = .init(width: 1600, height: 1500)
        
        junior.frame = .init(origin: .zero, size: CGSize(width: 100, height: 100))
        tmp.addSubview(junior)
        
        senior.frame = .init(origin: .init(x: 0, y: 200), size: CGSize(width: 100, height: 100))
        tmp.addSubview(senior)
        
        return tmp
    }()
    
    override func loadView() {
        view = UIView()
    
        view.addSubview(scrollView)
        scrollView.fillToSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollView.delegate = self
    }
}

extension TestVC: UIScrollViewDelegate {
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        junior
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
    }
}
