//
//  WordsGraphVC.swift
//  Semantics
//
//  Created by Zhou Wei Ran on 2020/6/20.
//  Copyright © 2020 Paper Scratch. All rights reserved.
//

import UIKit
import Highcharts

class WordsGraphVC: UIViewController {
    
    var chartView: HIChartView!
    
    override func loadView() {
        let chart = HIChart()
        chart.type = "networkgraph"
        chart.panning = HIPanning()
        chart.panning.enabled = true
        
        let title = HITitle()
        title.text = "Words Graph"
        
        let subtitle = HISubtitle()
        subtitle.text = "Direct Link"
        
        let plotOptions = HIPlotOptions()
        plotOptions.networkgraph = HINetworkgraph()
        plotOptions.networkgraph.keys = ["from", "to"]
        
        let networkgraph = HINetworkgraph()
        let dataLabels = HIDataLabels()
        dataLabels.enabled = NSNumber(booleanLiteral: true)
        let linkTextPath = HILinkTextPath()
        linkTextPath.enabled = true
        dataLabels.linkTextPath = linkTextPath
        dataLabels.linkFormat = "{point.annotation}"
        networkgraph.dataLabels = [dataLabels]
        let layoutAlgorithm = HILayoutAlgorithm()
        layoutAlgorithm.enableSimulation = NSNumber(booleanLiteral: true)
        networkgraph.layoutAlgorithm = layoutAlgorithm
        networkgraph.draggable = NSNumber(booleanLiteral: true)
        
        let options = HIOptions()
        options.chart = chart
        options.title = title
        options.subtitle = subtitle
        options.plotOptions = plotOptions
        options.series = [networkgraph]
        
        chartView = HIChartView()
        chartView.plugins = ["networkgraph"]
        chartView.options = options
        
        view = UIView()
        view.addSubview(chartView)
        
        
        tabBarItem = UITabBarItem(title: "Graph", image: UIImage(systemName: "tortoise"), selectedImage: UIImage(systemName: "tortoise.fill"))
    }
    
    override func viewDidLayoutSubviews() {
        chartView.frame = view.bounds
    }
    
    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(updateGraph), name: .NSManagedObjectContextObjectsDidChange, object: managedObjectContext)
        updateGraph()
    }
    
    @objc private func updateGraph() {
        let graph = chartView.options.series.first! as! HINetworkgraph
        
        let links = CoreDataLayer1.shared.queryLinks()
        let data = links.map { (link) -> [String: String] in
            let words = Array(link.words! as! Set<Word>)
            return ["from": words[0].name!, "to": words[1].name!, "annotation": link.annotation ?? ""]
        }
        if graph.data == nil {
            graph.data = data
        } else {
            graph.setSeriesData(data, redraw: NSNumber(booleanLiteral: true))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
