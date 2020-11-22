import UIKit
import WebKit
import FloatingPanel
import Combine
import NVActivityIndicatorView

protocol Phase {}

struct DayIndexPath {
    var phase: Phase
    var day: Int
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
    
    func updateBtns(forCellType cellType:  CellType) {
        switch cellType {
        case .Adding:
            [deleteBtn, addDayBtn].forEach {
                $0.isHidden = true
            }
            [nextDayBtn, closeBtn].forEach {
                $0.isHidden = false
            }
        case .Showing:
            [deleteBtn, addDayBtn, nextDayBtn, closeBtn].forEach {
                $0.isHidden = false
            }
        }
    }
}

extension PhasesVC: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        searchBar.setShowsCancelButton(true, animated: true)
        return true
    }
    
    func searchBarShouldEndEditing(_ searchBar: UISearchBar) -> Bool {
        //        searchBar.text
        return true
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.setShowsCancelButton(false, animated: false)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        phasesVM.addADay(url: URL(string: searchBar.text!)!)
    }
}

class PhasesVC: UIViewController, PanelContent {
    enum CellType {
        case Adding
        case Showing
    }
    
    lazy var spinner = Spinner.create()
    
    lazy var titleLabel: UILabel = {
        var tmp = UILabel()
        tmp.font = .preferredFont(forTextStyle: .largeTitle)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var progressView: UIProgressView = {
        var tmp = UIProgressView(progressViewStyle: .default)
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.progress = 0
        return tmp
    }()
    
    lazy var addingView: UISearchBar = {
        let tmp = Adding.createAddingLinkView(returnKeyType: .search)
        tmp.delegate = self
        return tmp
    }()
    
    lazy var deleteBtn = UIButton(systemName: "delete.right.fill", textStyle: .title2, target: self, selector: #selector(deleteBtnTapped))
    
    lazy var addDayBtn = UIButton(systemName: "plus.square.fill", textStyle: .title2, target: self, selector: #selector(addADayBtnTapped))
    
    lazy var nextDayBtn = UIButton(systemName: "forward.fill", textStyle: .title1, target: self, selector: #selector(nextDayBtnTapped))
    
    lazy var closeBtn = UIButton(systemName: "xmark.circle.fill", textStyle: .title1, target: self, selector: #selector(closeBtnTapped))
    
    lazy var interactionBar: UIStackView = {
        let tmp = UIStackView(arrangedSubviews: [deleteBtn, addDayBtn, nextDayBtn, closeBtn], axis: .horizontal, alignment: .top, distribution: .equalSpacing)
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
    
    private var onScreenView: UIView?
    
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
            DispatchQueue.main.async {
                self.reload()
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(titleLabel)
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalToSystemSpacingBelow: view.safeAreaLayoutGuide.topAnchor, multiplier: 1),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
                
        view.addSubview(progressView)
        NSLayoutConstraint.activate([
            progressView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 10),
            progressView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        view.addSubview(interactionBar)
        NSLayoutConstraint.activate([
            progressView.topAnchor.constraint(equalToSystemSpacingBelow: interactionBar.bottomAnchor, multiplier: 3),
            interactionBar.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            interactionBar.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor)
        ])
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UIView.animate(withDuration: 0.25) {
            self.panelContentDelegate.panel.move(to: .full, animated: false)
        }
        super.viewDidAppear(animated)
    }
    
    func showView(_ newView: UIView) {
        titleLabel.text = phasesVM.title
        progressView.setProgress(phasesVM.progress, animated: true)
        
        guard newView != onScreenView else {
            return
        }
        
        newView.isHidden = true
        newView.translatesAutoresizingMaskIntoConstraints = false
        view.insertSubview(newView, belowSubview: spinner)
        switch newView {
        case let newView as WKWebView:
            NSLayoutConstraint.activate([
                newView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
                newView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
                newView.topAnchor.constraint(equalToSystemSpacingBelow: titleLabel.bottomAnchor, multiplier: 2),
                interactionBar.topAnchor.constraint(equalTo: newView.bottomAnchor, constant: 20)
            ])
            updateBtns(forCellType: .Showing)
        case let newView as UISearchBar:
            newView.anchorCenterSuperview()
            NSLayoutConstraint.activate([
                newView.heightAnchor.constraint(equalToConstant: 44),
                newView.widthAnchor.constraint(equalTo: self.view.widthAnchor)
            ])
            updateBtns(forCellType: .Adding)
        default:
            fatalError()
        }
        view.layoutIfNeeded()
        
        let duration = 0.5
        let completion: (Bool) -> () = { _ in
            if let onScreenView = self.onScreenView as? WKWebView {
                self.webviewPool.put(onScreenView)
            }
            self.onScreenView = newView
            self.bufferingWebview = nil
        }
        if phasesVM.isTransitToNextPhase {
            newView.isHidden = false
            newView.transform = .init(translationX: 400, y: 0)
            UIView.transition(with: view, duration: duration, options: []) {
                self.onScreenView?.transform = .init(translationX: -400, y: 0)
                newView.transform = .identity
            } completion: { isFinished in
                self.onScreenView?.transform = .identity
                self.onScreenView?.removeFromSuperview()
                completion(isFinished)
            }
        } else {
            UIView.transition(with: view, duration: duration, options: [.transitionCrossDissolve], animations: {
                self.onScreenView?.removeFromSuperview()
                newView.isHidden = false
            }, completion: completion)
        }
    }
    
    @objc func nextDayBtnTapped() {
        phasesVM.updateDayIndexPathToNext()
        reload()
    }
    
    @objc func reload() {
        let cell = phasesVM.phasesVC(self, cellForDayAt: phasesVM.dayIndexPath)
        switch cell {
        case let cell as WKWebView:
            spinner.startAnimating()
            bufferingWebview = cell
        case let cell as UISearchBar:
            showView(cell)
        default:
            fatalError()
        }
    }

    @objc func addADayBtnTapped() {
        phasesVM.updateDayIndexPathByOneDay()
        reload()
    }
    
    @objc func deleteBtnTapped() {
        phasesVM.deleteADay()
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
    
    deinit {
        perspectiveInterpretationToken?.cancel()
    }
}
extension PhasesVC: WKNavigationDelegate {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        spinner.stopAnimating()
        showView(webView)
    }
}
