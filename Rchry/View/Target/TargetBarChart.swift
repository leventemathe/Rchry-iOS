//
//  TargetBarChart.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 11. 07..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import Charts
import RxSwift

class TargetBarChart: BarChartView {
        
    private var colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    func setNoDataText(_ text: String) {
        noDataText = text
        noDataTextColor = UIColor(named: "ColorThemeDark")!
        noDataFont = UIFont(name: "Amatic-Bold", size: 24)!
    }
    
    func setGestures(_ gestures: Bool) {
        isUserInteractionEnabled = gestures
    }

    func subscribe(_ userData: Observable<UserScoreData>,
                   decimalPrecision precision: Int,
                   minimumScore: Float) -> Disposable {
        return userData
            .subscribe(onNext: { [unowned self] userScore in
                if userScore.scoresBySession.count < 1 {
                    self.data = nil
                    return
                }
                let user = userScore.user
                let entries = self.buildEntries(fromAverageScoresBySession: userScore.scoresBySession)
                self.refreshBarchartData(user, fromEntries: entries)
                self.refreshBarChartLooks(entries.count,
                                          startTimestamp: userScore.startTimestamp,
                                          endTimestamp: userScore.endTimestamp,
                                          decimalPrecision: precision,
                                          minimumScore: minimumScore)
            })
    }
    
    private func buildEntries(fromAverageScoresBySession scores: [(String, Float)]) -> [BarChartDataEntry] {
        var entries = [BarChartDataEntry]()
        for (i, val) in scores.enumerated() {
            let entry = BarChartDataEntry(x: Double(i), y: Double(val.1))
            entries.append(entry)
        }
        return entries
    }
    
    private func refreshBarchartData(_ user: String, fromEntries entries: [BarChartDataEntry]) {
        // Each user should have a dataset, where the label is their name.
        let dataSet = BarChartDataSet(values: entries, label: user)
        dataSet.colors = [self.colors[0]]
        let data = BarChartData(dataSets: [dataSet])
        self.data = data
    }
    
    private func refreshBarChartLooks(_ barCount: Int,
                                      startTimestamp start: Double,
                                      endTimestamp end: Double,
                                      decimalPrecision precision: Int,
                                      minimumScore: Float) {
        refreshBarChartLooksCommon(startTimestamp: start, endTimestamp: end, decimalPrecisision: precision, minimumScore: minimumScore)
        if barCount < changeDataLabelLookLimit {
            data?.setDrawValues(true)
            leftAxis.drawGridLinesEnabled = false
            leftAxis.drawLabelsEnabled = false
            leftAxis.drawAxisLineEnabled = false
        } else {
            data?.setDrawValues(false)
            leftAxis.drawGridLinesEnabled = true
            leftAxis.drawLabelsEnabled = true
            leftAxis.drawAxisLineEnabled = true
        }
    }
    
    private let changeDataLabelLookLimit = 8
    
    private func refreshBarChartLooksCommon(startTimestamp start: Double,
                                            endTimestamp end: Double,
                                            decimalPrecisision precision: Int,
                                            minimumScore: Float) {
        chartDescription?.text = ""
        
        data?.setValueFont(UIFont(name: "Lato-Regular", size: 8)!)
        data?.setValueTextColor(UIColor(named: "ColorThemeDark")!)
        data?.setValueFormatter(TargetBarChartDataValueFormatter(minFractionDigits: precision, maxFractionDigits: precision))
        
        legend.textColor = UIColor(named: "ColorThemeDark")!
        legend.font = UIFont(name: "Lato-Regular", size: 10)!
        
        xAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        xAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        xAxis.labelPosition = .bottom
        
        xAxis.drawLabelsEnabled = true
        xAxis.axisMaxLabels = 2
        xAxis.granularity = 1.0
        xAxis.granularityEnabled = true
        xAxis.valueFormatter = TargetBarChartXAxisValueFormatter(startTimestamp: start, endTimestamp: end)
        xAxis.drawGridLinesEnabled = false
        
        if let entryCount = barData?.entryCount {
            if entryCount > changeDataLabelLookLimit {
                xAxis.avoidFirstLastClippingEnabled = true
            } else {
                xAxis.avoidFirstLastClippingEnabled = false
            }
            
        } else {
            xAxis.avoidFirstLastClippingEnabled = false
        }
        
        leftAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        leftAxis.gridColor = UIColor(named: "ColorThemeMid")!
        leftAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        leftAxis.labelFont = UIFont(name: "Lato-Regular", size: 10)!
        leftAxis.axisMinimum = Double(minimumScore)
        leftAxis.valueFormatter = TargetBarChartYAxisValueFormatter(minFractionDigits: precision, maxFractionDigits: precision)
        
        rightAxis.drawGridLinesEnabled = false
        rightAxis.drawLabelsEnabled = false
        rightAxis.drawAxisLineEnabled = false
    }
}



class TargetBarChartDataValueFormatter: IValueFormatter {
    
    private let minFractionDigits: Int
    private let maxFractionDigits: Int
    
    init(minFractionDigits: Int, maxFractionDigits: Int) {
        self.minFractionDigits = minFractionDigits
        self.maxFractionDigits = maxFractionDigits
    }
    
    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        return Float(value).prettyString(minFractionDigits: minFractionDigits, maxFractionDigits: maxFractionDigits)!
    }
}

class TargetBarChartYAxisValueFormatter: IAxisValueFormatter {
    
    private let minFractionDigits: Int
    private let maxFractionDigits: Int
    
    init(minFractionDigits: Int, maxFractionDigits: Int) {
        self.minFractionDigits = minFractionDigits
        self.maxFractionDigits = maxFractionDigits
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        return Float(value).prettyString(minFractionDigits: minFractionDigits, maxFractionDigits: maxFractionDigits)!
    }
}

class TargetBarChartXAxisValueFormatter: IAxisValueFormatter {
    
    let dateProvider: DateProvider
    let startTimestamp: Double
    let endTimestamp: Double
    
    init(startTimestamp: Double, endTimestamp: Double, dateProvider: DateProvider = BasicDateProvider()) {
        self.dateProvider = dateProvider
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
    }
    
    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let entries = axis?.entries, let firstEntry = entries.first, let lastEntry = entries.last else {
            return ""
        }
        if value == firstEntry {
            return dateProvider.dateString(fromTimestamp: startTimestamp)
        } else if value == lastEntry {
            return dateProvider.dateString(fromTimestamp: endTimestamp)
        }
        return ""
    }
}


