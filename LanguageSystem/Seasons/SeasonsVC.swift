import UIKit
import WebKit
import MHLoadingButton
import FloatingPanel
// [-][--][---][-]

class SeasonsVC: UIViewController, PanelContent {
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    
    var showBackBtn = false
    
    var panelContentVM: PanelContentVM!
    
    let urls = [
        "https://finland.fi/zh/emoji/tiane/",
        
        "https://finland.fi/zh/emoji/buzaibangongshi/",
        "https://finland.fi/zh/emoji/baiye-2/",
        "https://finland.fi/zh/emoji/kokko-4/",
        "https://finland.fi/zh/emoji/lavatanssit-4/",
        
        "https://finland.fi/zh/emoji/dongzhu/",
        "https://finland.fi/zh/emoji/kaamos-10/",
        "https://finland.fi/zh/emoji/xiong/",
        "https://finland.fi/zh/emoji/shengdanpaidui/"
    ]
    
    lazy var spinner: UIActivityIndicatorView = {
        let tmp = UIActivityIndicatorView()
        tmp.style = .large
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var titleLabel: UILabel = {
        var tmp = UILabel()
        tmp.font = .preferredFont(forTextStyle: .largeTitle)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var progressView: UIProgressView = {
        var tmp = UIProgressView(progressViewStyle: .default)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    let webviewPool: [WKWebView] = {
        var tmp = [WKWebView(), WKWebView()]
        tmp.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.cornerRadius = 10
            $0.clipsToBounds = true
        }
        return tmp
    }()
    
    lazy var interactionBar: UIStackView = {
        let edit = UIButton(systemName: "pencil.circle.fill", textStyle: .title2, target: nil, selector: nil)
        
        let add = UIButton(systemName: "plus.square.fill", textStyle: .title2, target: nil, selector: nil)

        let play = UIButton(systemName: "forward.fill", textStyle: .title1, target: self, selector: #selector(loadADay))
        
        let close = UIButton(systemName: "xmark.circle.fill", textStyle: .title1, target: self, selector: #selector(closeBtnTapped))
    
                
        let tmp = UIStackView(arrangedSubviews: [edit, add, play, close], axis: .horizontal, alignment: .top, distribution: .equalSpacing)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
//    lazy var  button: LoadingButton = {
//        let tmp = LoadingButton(text: "Next", textColor: .white, bgColor: .systemBlue)
//        tmp.indicator = UIActivityIndicatorView()
//
//        tmp.translatesAutoresizingMaskIntoConstraints = false
//        tmp.heightAnchor.constraint(equalToConstant: 40).isActive = true
//
//        tmp.addTarget(self, action: #selector(btnTapped), for: .touchUpInside)
//        return tmp
//    }()
    
    var index = 0
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(progressView)
        view.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 3),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
        
        view.addSubview(interactionBar)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: interactionBar.bottomAnchor, multiplier: 1),
            interactionBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            interactionBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        view.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    override func viewDidLoad() {
        loadADay()
    }
    
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
        
    func replaceWebview(_ webview: WKWebView, with: WKWebView) {
        if [1,5].contains(index) {
            self.view.insertSubview(with, belowSubview: spinner)
            NSLayoutConstraint.activate([
                with.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
                with.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
                with.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 2),
                self.interactionBar.topAnchor.constraint(equalTo: with.bottomAnchor, constant: 20)
            ])
            with.transform = .init(translationX: 400, y: 0)
            UIView.transition(with: view, duration: 1, options: []) {
                webview.transform = .init(translationX: -400, y: 0)
                with.transform = .identity
            } completion: { _ in
                webview.transform = .identity
                webview.removeFromSuperview()
            }
        } else {
            UIView.transition(with: self.view, duration: 1, options: .transitionCrossDissolve) {
                webview.removeFromSuperview()
                self.view.insertSubview(with, belowSubview: self.spinner)
                NSLayoutConstraint.activate([
                    with.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
                    with.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
                    with.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 2),
                    self.interactionBar.topAnchor.constraint(equalTo: with.bottomAnchor, constant: 20)
                ])
            } completion: { _ in
            }
        }
    }
    
    @objc func loadADay() {
        guard index < urls.count else {
            return
        }
        
        spinner.startAnimating()
        let webview = self.index % 2 == 0 ? self.webviewPool[0] : self.webviewPool[1]
        webview.navigationDelegate = self
        webview.load(URLRequest(urlString: self.urls[self.index])!)
    }
    
    @objc func closeBtnTapped() {
        panelContentDelegate.panelContentVC.hideTop()
    }
}
extension SeasonsVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("[WK] didStartProvisionalNavigation")
    }
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        print("[WK] didCommit")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("[WK] didFinish")
        spinner.stopAnimating()
        let ori = index % 2 == 0 ? webviewPool[1] : webviewPool[0]
        let aft = index % 2 == 0 ? webviewPool[0] : webviewPool[1]
        replaceWebview(ori, with: aft)
        if index == 0 {
            titleLabel.text = "Spring"
        } else if index <= 4 {
            titleLabel.text = "Summer"
        } else {
            titleLabel.text = "Winter"
        }
        index += 1
        progressView.setProgress(Float(index) / Float(urls.count), animated: true)
    }
}
