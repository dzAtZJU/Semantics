import RealmSwift

protocol PanelContentVM {
    var panelContentVMDelegate: PanelContentVMDelegate! { get set }
    
    var thePlaceId: String? {
        get
    }
}

protocol PanelContentVMDelegate {
    var mapVM: MapVM {
        get
    }
}
