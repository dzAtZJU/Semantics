import WebKit
import UIKit

class WebViewController: UIViewController, WKNavigationDelegate {
    
    private var completion: (() -> ())!
    
    private lazy var webView: WKWebView = {
        let webConfiguration = WKWebViewConfiguration()
        let tmp = WKWebView(frame: .zero, configuration: webConfiguration)
        tmp.navigationDelegate = self
        return tmp
    }()
    
    override func loadView() {
           view = webView
    }
    
    func load(url: URL, completion: @escaping () -> ()) {
        webView.load(URLRequest(url: url))
        self.completion = completion
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.completion()
    }
}
