//
//  TargetChartVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 06..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import Charts

class TargetChartVC: UIViewController {
    
    @IBOutlet weak var barChart: BarChartView!
    
    // TODO: move entry and model to model and vm
    /*
    private let dummyModelForChart = [
        ("first", 5.1),
        ("second", 4.2),
        ("third", 6.3),
        ("asd", 6.1),
        ("qwe", 8.3),
        ("fsgdsdafdsfgsdghhfdgfhgfdhdfghfgsdfgsfdg", 7.5),
        ("gdsfgdfsgdfs", 8.0),
    ]
 */

    
    private let dummyModelForChart = [
        ("first", 5.1),
        ("second", 4.2),
        ("third", 6.3)
        ]
 
    /*
    private let dummyModelForChart = [
        ("first", 5.1),
        ("second", 4.2),
        ("third", 6.3),
        ("asd", 6.1),
        ("qwe", 8.3),
        ("fsgdsdafdsfgsdghhfdgfhgfdhdfghfgsdfgsfdg", 7.5),
        ("gdsfgdfsgdfs", 7.1),
        ("gdsfgdfsgdfs", 8.2),
        ("gdsfgdfsgdfs", 8.5),
        ("gdsfgdfsgdfs", 8.6),
        ("gdsfgdfsgdfs", 8.7),
        ("gdsfgdfsgdfs", 8.2),
        ("gdsfgdfsgdfs", 8.9),
        ("gdsfgdfsgdfs", 9.2),
        ("gdsfgdfsgdfs", 6.5),
        ("gdsfgdfsgdfs", 6.8),
        ("gdsfgdfsgdfs", 8.2),
        ("gdsfgdfsgdfs", 8.3),
        ("gdsfgdfsgdfs", 9.2),
        ("gdsfgdfsgdfs", 7.2),
        ("gdsfgdfsgdfs", 6.5),
        ("gdsfgdfsgdfs", 6.4),
        ("gdsfgdfsgdfs", 9.1),
        ("gdsfgdfsgdfs", 9.2),
        ("gdsfgdfsgdfs", 9.0),
        ("gdsfgdfsgdfs", 8.9),
        ("gdsfgdfsgdfs", 9.8)
        ]
 */
    
    private let colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    override func viewDidLoad() {
        setupBarChart()
    }
    
    private func setupBarChart() {
        setupBarChartNoDataText()
        setupBarChartData()
        setupBarChartLooks()
    }
    
    private func setupBarChartNoDataText() {
        barChart.noDataText = NSLocalizedString("TargetChartNoDataText", comment: "The text to display when there is no data yet for the chart for a target: average scores per session.")
        barChart.noDataTextColor = UIColor(named: "ColorThemeDark")!
        barChart.noDataFont = UIFont(name: "Amatic-Bold", size: 24)!
    }
    
    private func setupBarChartData() {
        var entries = [BarChartDataEntry]()
        for (i, val) in dummyModelForChart.enumerated() {
            let entry = BarChartDataEntry(x: Double(i), y: val.1)
            entries.append(entry)
        }
        
        // Each user should have a dataset, where the label is their name.
        let dataSet = BarChartDataSet(values: entries, label: "my_scores")
        dataSet.colors = [colors[0]]
        let data = BarChartData(dataSets: [dataSet])
    
        barChart.data = data
    }
    
    private func setupBarChartLooks() {
        let formatter = TargetBarChartFormatter(dummyModelForChart.map { $0.0 })
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        barChart.xAxis.valueFormatter = xAxis.valueFormatter
        
        if dummyModelForChart.count > 4 {
            barChart.xAxis.drawLabelsEnabled = false
        } else {
            barChart.xAxis.setLabelCount(dummyModelForChart.count, force: false)
            barChart.xAxis.wordWrapEnabled = true
            barChart.xAxis.labelFont = UIFont(name: "Lato-Regular", size: 8)!
        }
        
        barChart.data?.setValueFont(UIFont(name: "Lato-Regular", size: 8)!)
        
        barChart.xAxis.drawGridLinesEnabled = false
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        barChart.xAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        
        barChart.leftAxis.drawGridLinesEnabled = false
        barChart.leftAxis.drawLabelsEnabled = false
        barChart.leftAxis.drawAxisLineEnabled = false
        
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
    
        barChart.chartDescription?.text = ""
        
        barChart.legend.textColor = UIColor(named: "ColorThemeDark")!
        barChart.legend.font = UIFont(name: "Lato-Regular", size: 10)!
        barChart.data?.setValueTextColor(UIColor(named: "ColorThemeDark")!)
    }
}

class TargetBarChartFormatter: IAxisValueFormatter {
    
    private let strings: [String]
    
    init(_ strings: [String]) {
        self.strings = strings
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let i = Int(value)
        if i < strings.count && i >= 0 {
            return strings[i]
        }
        return ""
    }
}
