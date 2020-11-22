import ResearchKit
//https://github.com/ResearchKit/ResearchKit/blob/master/docs/ChartsAndGraphs/ChartsAndGraphs-template.markdown


class PollView: ORKPieChartView, UIContentView, ORKPieChartViewDataSource {
    var configuration: UIContentConfiguration {
        didSet {
            update()
        }
    }
    
    init(configuration configuration_: PollContentConfiguration) {
        configuration = configuration_
        
        super.init(frame: .zero)
        showsTitleAboveChart = true
        dataSource = self
        
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var pollContentConfiguration: PollContentConfiguration {
        configuration as! PollContentConfiguration
    }
    
    func update() {
        title = pollContentConfiguration.opinion.title
        reloadData()
    }
    
    func numberOfSegments(in pieChartView: ORKPieChartView) -> Int {
        2
    }
    
    func pieChartView(_ pieChartView: ORKPieChartView, valueForSegmentAt index: Int) -> CGFloat {
        let opinionData = pollContentConfiguration.opinion.opinionData as! Opinion.Poll
        return CGFloat(index == 0 ? (opinionData.agreePortion) : (100 - opinionData.agreePortion))
    }
}

struct PollContentConfiguration: UIContentConfiguration {
    func updated(for state: UIConfigurationState) -> PollContentConfiguration {
        self
    }
    
    func makeContentView() -> UIView & UIContentView {
        PollView(configuration: self)
    }
    
    let opinion: Opinion
}
