import UIKit
import Presentr

class ProfileVC: UIViewController {
    lazy var presentr: Presentr = {
        let tmp = Presentr(presentationType: .dynamic(center: .customOrigin(origin: .zero)))
        tmp.transitionType = .coverVerticalFromTop
        tmp.dismissTransitionType = .coverVerticalFromTop
        return tmp
    }()
    
    lazy var avatarView: UIImageView = {
        let tmp = Profile.createAvatarView(width: 80)
        tmp.isUserInteractionEnabled = true
        tmp.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(imgViewTapped)))
        return tmp
    }()
    
    lazy var shareBtn: UIButton = UIButton(systemName: "square.and.arrow.up", textStyle: .title2, primaryAction: UIAction(handler: { _ in
        let items = [URL(string: "https://semantics-dev-wvrwg-uclmi.mongodbstitch.com/invitation/\(RealmSpace.userID!)")!]
        let ac = UIActivityViewController(activityItems: items, applicationActivities: nil)
        self.present(ac, animated: true)
    }))
    
    
    lazy var nameField: UITextField = {
        let tmp = UITextField()
        tmp.placeholder = "name"
        tmp.font = .preferredFont(forTextStyle: .title1)
        tmp.textAlignment = .center
        tmp.translatesAutoresizingMaskIntoConstraints = false
        tmp.delegate = self
        return tmp
    }()
    
    lazy var stack: UIStackView = {
        let tmp = UIStackView(arrangedSubviews: [avatarView, nameField], axis: .vertical)
        tmp.alignment = .center
        tmp.translatesAutoresizingMaskIntoConstraints = false
        return tmp
    }()
    
    lazy var spinner = Spinner.create()
    
    private var stackHeightConstraint: NSLayoutConstraint!
    
    private var titleToken: NSKeyValueObservation?
    
    private var avatarToken: NSKeyValueObservation?
    
    private var ind: Individual!
    
    override func loadView() {
        view = UIView()
        view.backgroundColor = .secondarySystemBackground
        
        view.addSubview(stack)
        stack.anchorBottomCenter()
        stackHeightConstraint = stack.heightAnchor.constraint(equalTo: view.heightAnchor)
        stackHeightConstraint.isActive = true
        
        view.addSubview(shareBtn)
        shareBtn.anchorTopTrailing()
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let action: ()->() = {
            self.ind = RealmSpace.main.privatRealm.queryCurrentIndividual()!
            self.nameField.text = self.ind.title
            self.titleToken = self.ind.observe(\.title, options: .new) { (_, change) in
                self.nameField.text = change.newValue!
            }
            if let data = self.ind.avatar {
                self.avatarView.image = UIImage(data: data)
            }
            self.avatarToken = self.ind.observe(\.avatar, options: .new) { (_, change) in
                if let data = change.newValue! {
                    self.avatarView.image = UIImage(data: data)
                }
            }
        }
        
        if RealmSpace.isPreloaded {
            action()
        } else {
            spinner.startAnimating()
            NotificationCenter.default.addObserver(forName: .realmsPreloaded, object: nil, queue: nil) { _ in
                action()
                self.spinner.stopAnimating()
            }
        }
    }
    
    override func viewSafeAreaInsetsDidChange() {
        stackHeightConstraint.constant = -view.safeAreaInsets.top
    }
    
    @objc func imgViewTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
}
extension ProfileVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        let text = textField.text
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.privatRealm.modifyName(text)
        }
        textField.resignFirstResponder()
        return true
    }
}

extension ProfileVC: UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    public func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    public func imagePickerController(_ picker: UIImagePickerController,
                                      didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
        let image = info[.editedImage] as! UIImage
        RealmSpace.userInitiated.async {
            RealmSpace.userInitiated.privatRealm.modifyAvatar(image.pngData())
        }
        picker.dismiss(animated: true, completion: nil)
    }
}
