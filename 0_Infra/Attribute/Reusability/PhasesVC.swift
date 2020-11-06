import UIKit
import WebKit
import MHLoadingButton
import FloatingPanel
import Combine

protocol Phase {}

struct DayIndexPath {
    let phase: Phase
    let day: Int
}

// [][][][]
// [--][---][--][----]
protocol PhasesVCDatasource {
    func phasesVC(_ phasesVC: PhasesVC, cellForDayAt: DayIndexPath) -> UIView
}

extension PhasesVC {
    func dequeueReusableCell(withCellType cellType: CellType,
                             for dayIndexPath: DayIndexPath) -> UIView {
        switch cellType {
        case .Adding:
            return addingView
        case .Showing:
            return webviewPool.get()
        }
    }
}

class PhasesVC: UIViewController, PanelContent {
    enum CellType {
        case Adding
        case Showing
    }
    
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
    
    lazy var addingView = Adding.createAddingLinkView()
    
    lazy var interactionBar: UIStackView = {
        let delete = UIButton(systemName: "delete.right.fill", textStyle: .title2, target: self, selector: #selector(deleteADay))
        
        let addDay = UIButton(systemName: "plus.square.fill", textStyle: .title2, target: self, selector: #selector(addADay))

        let nextDay = UIButton(systemName: "forward.fill", textStyle: .title1, target: self, selector: #selector(reload))
        
        let close = UIButton(systemName: "xmark.circle.fill", textStyle: .title1, target: self, selector: #selector(closeBtnTapped))
    
                
        let tmp = UIStackView(arrangedSubviews: [delete, addDay, nextDay, close], axis: .horizontal, alignment: .top, distribution: .equalSpacing)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var webviewPool: Pool<WKWebView> = {
        var tmp = [WKWebView(), WKWebView()]
        tmp.forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            $0.cornerRadius = 10
            $0.clipsToBounds = true
        }
        
        return Pool(instances: tmp)
    }()
    
    let phasesVM: SeasonsVM
    
    private var bufferingWebview: WKWebView?
    
    private var onScreenWebview: WKWebView?
    
    var phasesVCDatasource: PhasesVCDatasource?
    
    var perspectiveInterpretationToken: AnyCancellable?
    
    //
    var prevPanelState:  FloatingPanelState?
    
    var panelContentDelegate: PanelContentDelegate!
    
    var showBackBtn = false
    
    var panelContentVM: PanelContentVM!
    
    init(seasonsVM seasonsVM_: SeasonsVM) {
        phasesVM = seasonsVM_
        super.init(nibName: nil, bundle: nil)
        
        perspectiveInterpretationToken = phasesVM.$seasonInterpretation.sink { newValue in
            self.reload()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .full, animated: false)
        }
        super.viewDidAppear(animated)
    }
    
    @objc func reload() {
        spinner.startAnimating()
        let cell = phasesVM.phasesVC(self, cellForDayAt: phasesVM.dayIndexPath)
        switch cell {
        case let cell as WKWebView:
            bufferingWebview = cell
        case let cell as UISearchBar:
            showView(cell)
        default:
            fatalError()
        }
    }
    
    func showView(_ view: UIView) {
        UIView.transition(with: self.view, duration: 1, options: .transitionCrossDissolve) {
            self.onScreenWebview?.removeFromSuperview()
            self.view.insertSubview(view, belowSubview: self.spinner)
            view.translatesAutoresizingMaskIntoConstraints = false
            view.fillToSuperview()
        } completion: { _ in
        }
    }
    
    @objc func addADay() {

    }
    
    @objc func deleteADay() {
        
    }
    
    @objc func closeBtnTapped() {
        panelContentDelegate.panelContentVC.hideTop()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        if let prevPanelState = prevPanelState {
            UIView.animate(withDuration: 0.25) {
                self.panelContentDelegate.panel.move(to: prevPanelState, animated: false)
            }
        }
        super.viewWillDisappear(animated)
    }

    func replaceWebview(_ webview: WKWebView?, with: WKWebView) {
//        NSLayoutConstraint.activate([
//            with.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
//            with.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
//            with.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 2),
//            self.interactionBar.topAnchor.constraint(equalTo: with.bottomAnchor, constant: 20)
//        ])
//        if [1,5].contains(index) {
//            self.view.insertSubview(with, belowSubview: spinner)
//            NSLayoutConstraint.activate([
//                with.leadingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.leadingAnchor),
//                with.trailingAnchor.constraint(equalTo: self.view.layoutMarginsGuide.trailingAnchor),
//                with.topAnchor.constraint(equalToSystemSpacingBelow: self.view.topAnchor, multiplier: 2),
//                self.interactionBar.topAnchor.constraint(equalTo: with.bottomAnchor, constant: 20)
//            ])
//            with.transform = .init(translationX: 400, y: 0)
//            UIView.transition(with: view, duration: 1, options: []) {
//                webview?.transform = .init(translationX: -400, y: 0)
//                with.transform = .identity
//            } completion: { _ in
//                webview?.transform = .identity
//                webview?.removeFromSuperview()
//            }
//        }
    }
    
    deinit {
        perspectiveInterpretationToken?.cancel()
    }
}
extension PhasesVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        replaceWebview(onScreenWebview, with: bufferingWebview!)
//        titleLabel.text
//        progressView.setProgress()
    }
}
