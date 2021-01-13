import Mapbox
import Metron
import SemGeometry
import PhotosUI
import CoreLocation
import Combine

class TileMapVC: UIViewController {
    private lazy var spinner = Spinner.create()
    
    private var map: MGLMapView = {
        let tmp = MGLMapView(frame: .zero, styleURL: URL(string: "mapbox://styles/paper-scratch/ckii8bgaj030z19rxkz070vzh")!)
        tmp.setCenter(.init(latitude: 35.7, longitude: 139.7), zoomLevel: 16, animated: false)
        return tmp
    }()
    
    init() {
        super.init(nibName: nil, bundle: nil)
        let img = UIImage(systemName: "photo.on.rectangle.angled")?.withBaselineOffset(fromBottom: UIFont.systemFontSize/4)
        tabBarItem = UITabBarItem(title: "贴图", image: img, selectedImage: img)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = map
        
        view.addSubview(spinner)
        spinner.anchorCenterSuperview()
    }
    
    public var vm: ATileMapVM! {
        didSet {
            connectable = vm.pub.makeConnectable()
            if isMapLoaded {
                connect = nil
                sink = connectable!.autoconnect()
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] in
                        self.renderTile(imgSource: $0)
                    }
            } else {
                sink = connectable!
                    .receive(on: DispatchQueue.main)
                    .sink { [unowned self] in
                        self.renderTile(imgSource: $0)
                    }
            }
            
        }
    }
    
    private var connectable: Publishers.MakeConnectable<AnyPublisher<MGLImageSource, Never>>?
    private var sink: AnyCancellable?
    private var connect: Cancellable?
    
    private var selectedFeatureCoords: [CLLocationCoordinate2D]?
    
    private var isMapLoaded = false
    
    private var snapshot = Set<String>()
    
    override func viewDidLoad() {
        spinner.startAnimating()
        
        map.delegate = self
        
        let action: () -> () = {
            RealmSpace.userInitiated.async { [weak self] in
                guard let self = self else {
                    return
                }
                
                let vm = ATileMapVM(on: RealmSpace.userInitiated.queue)
                vm.m = ATileMapM(realm: RealmSpace.userInitiated.privatRealm)
                self.vm = vm
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
            }
        }
        if RealmSpace.isPreloaded {
            action()
        } else {
            var token: NSObjectProtocol?
            token = NotificationCenter.default.addObserver(forName: .realmsPreloaded, object: nil, queue: nil) { _ in
                action()
                NotificationCenter.default.removeObserver(token!)
            }
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleMapTap(sender:)))
        for recognizer in map.gestureRecognizers! where recognizer is UITapGestureRecognizer {
            singleTap.require(toFail: recognizer)
        }
        map.addGestureRecognizer(singleTap)
    }
    
    @objc @IBAction func handleMapTap(sender: UITapGestureRecognizer) {
        let spot = sender.location(in: map)
        for case let layer as MGLFillStyleLayer in map.style!.layers {
            guard let feature = map.visibleFeatures(at: spot, styleLayerIdentifiers: [layer.identifier]).first else {
                continue
            }
            
            selectedFeatureCoords = feature.coords
            
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            present(picker, animated: true)
            break
        }
    }
    
    private func renderTile(imgSource: MGLImageSource) {
        guard !snapshot.contains(imgSource.identifier) else {
            return
        }
        defer {
            snapshot.insert(imgSource.identifier)
        }
        
        let layer = MGLRasterStyleLayer(identifier: imgSource.identifier, source: imgSource)
        map.style!.addSource(imgSource)
        map.style!.addLayer(layer)
    }
}

extension TileMapVC: MGLMapViewDelegate {
    func mapViewDidFinishLoadingMap(_ mapView: MGLMapView) {
        isMapLoaded = true
        
        RealmSpace.userInitiated.async {
            self.connect = self.connectable?.connect()
        }
    }
    
    func mapViewDidFailLoadingMap(_ mapView: MGLMapView, withError error: Error) {
        print("[Error]: \(error)")
    }
}

extension TileMapVC: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        
        if let result = results.first {
            result.itemProvider.loadObject(ofClass: UIImage.self) { [weak self] (image, error) in
                guard let self = self, let selectedFeatureCoords = self.selectedFeatureCoords else { return }
                
                let newImgSource = self.vm.generateTile(image: image as! UIImage, coords: selectedFeatureCoords)
                self.renderTile(imgSource: newImgSource)
            }
        }
    }
}
