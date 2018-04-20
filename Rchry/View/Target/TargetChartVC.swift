//
//  TargetChartVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 06..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import Charts
import RxSwift

class TargetChartVC: UIViewController {
    
    
    @IBOutlet weak var userPickerTextfield: UITextField!
    @IBOutlet weak var barChart: BarChartView!
    
    @IBOutlet weak var averageLbl: UILabel!
    @IBOutlet weak var diffLbl: UILabel!
    @IBOutlet weak var maxLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    
    var targetChartVM: TargetChartVM!
    private var disposeBag = DisposeBag()
    
    // Chart and picker views should be refreshed with new data whenever the vc appears.
    private var pickerDisposeBag: DisposeBag!
    private var chartDisposeBag: DisposeBag!
    
    // Every time a different user is picked, I need to clear the subs to statistics for the old user.
    // Recreate this when changing user.
    private var statisticsDisposeBag: DisposeBag!
    
    private var colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarChartNoDataText()
        setupbarChartGestures()
        setupUserPickerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        engage()
        refreshUserPickerViews()
        refreshBarChartAndStatistics()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disengage()
        super.viewWillDisappear(animated)
    }
    
    private func engage() {
        targetChartVM.engage()
        pickerDisposeBag = DisposeBag()
        chartDisposeBag = DisposeBag()
    }
    
    private func disengage() {
        targetChartVM.disengage()
        pickerDisposeBag = nil
        chartDisposeBag = nil
    }
    
    private func setupBarChartNoDataText() {
        barChart.noDataText = NSLocalizedString("TargetChartNoDataText", comment: "The text to display when there is no data yet for the chart for a target: average scores per session.")
        barChart.noDataTextColor = UIColor(named: "ColorThemeDark")!
        barChart.noDataFont = UIFont(name: "Amatic-Bold", size: 24)!
    }
    
    private func setupbarChartGestures() {
        barChart.isUserInteractionEnabled = false
    }
    
    private func setupUserPickerViews() {
        let userPicker = createUserPickerView()
        setupUserPickerTextField(userPicker)
    }
    
    private func createUserPickerView() -> UIPickerView {
        let userPicker = UIPickerView()
        userPicker.backgroundColor = UIColor.white
        addToolbarToUserPicker()
        
        userPicker.rx.modelSelected(String.self)
            .map { $0[0] }
            .bind(to: userPickerTextfield.rx.text)
            .disposed(by: disposeBag)
        
        return userPicker
    }
    
    private func addToolbarToUserPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor(named: "ColorThemeMid")
        
        toolbar.setItems([createDoneButtonForToolbar()], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        userPickerTextfield.inputAccessoryView = toolbar
    }
    
    private func createDoneButtonForToolbar() -> UIBarButtonItem {
        let doneButtonText = NSLocalizedString("TargetChartUserSelectionDone", comment: "The user selected a target, and they press this button to leave the selector view.")
        let doneButton = UIBarButtonItem(title: doneButtonText, style: .done, target: self, action: #selector(TargetChartVC.dismissUserPickerView))
        doneButton.tintColor = UIColor.white
        doneButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Amatic-Bold", size: 26.0)!], for: .normal)
        return doneButton
    }
    
    @objc private func dismissUserPickerView() {
        view.endEditing(true)
    }
    
    private func setupUserPickerTextField(_ userPicker: UIPickerView) {
        userPickerTextfield.text = ShotNames.MY_SCORE
        userPickerTextfield.inputView = userPicker
    }
    
    private func setupStatisticsLabels(_ user: String) {
        statisticsDisposeBag = nil
        statisticsDisposeBag = DisposeBag()
        targetChartVM.average(forUser: user).bind(to: averageLbl.rx.text).disposed(by: statisticsDisposeBag)
        targetChartVM.min(forUser: user).bind(to: minLbl.rx.text).disposed(by: statisticsDisposeBag)
        targetChartVM.max(forUser: user).bind(to: maxLbl.rx.text).disposed(by: statisticsDisposeBag)
        targetChartVM.diff(forUser: user).bind(to: diffLbl.rx.text).disposed(by: statisticsDisposeBag)
    }
    
    private func refreshUserPickerViews() {
        let pickerView = userPickerTextfield.inputView as! UIPickerView
        targetChartVM.guests
            .bind(to: pickerView.rx.items) { [unowned self] row, element, view in
                var label: UILabel!
                if let view = view as? UILabel {
                    label = view
                }
                label = self.createLabelForUserPicker(element)
                return label
            }
            .disposed(by: pickerDisposeBag)
    }
    
    private func createLabelForUserPicker(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "ColorThemeDark")
        label.textAlignment = .center
        label.font = UIFont(name: "Lato-Regular", size: 18)
        return label
    }
    
    private func refreshBarChartAndStatistics() {
        let userText = userPickerTextfield.rx.text.asObservable()
        userText
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [unowned self] user in
                if user == ShotNames.ALL_SCORES {
                    self.refreshBarChartForAllUsers()
                } else {
                    self.refreshBarchartForSingleUser(user)
                    self.setupStatisticsLabels(user)
                }
            }).disposed(by: chartDisposeBag)
    }
    
    private func refreshBarChartForAllUsers() {
        targetChartVM.averageScoresPerUserBySession
            .subscribe(onNext: { averageScoreBySessionByUser in
                let userCount = averageScoreBySessionByUser.count
                // Because not all users take part in all sessions,
                // the indexes for the entries can be off.
                // Because of this, I assign indexes to the session names,
                // that way sessions where the user didn't participate, can be skipped.
                let sessionNameIndexes = self.targetChartVM.sessionNameIndexes(fromAverageScoresBySessionPerUser: averageScoreBySessionByUser)
                var dataSets = self.buildDatasetsForMultipleUsers(fromAverageScoresBySessionPerUser: averageScoreBySessionByUser,
                                                                  withSessionNameIndexes: sessionNameIndexes,
                                                                  withUserCount: userCount)
                self.setColorsForDatasetsForMultipleUsers(&dataSets)
                self.refreshDataForMultipleUsers(dataSets, withUserCount: userCount)
                self.refreshBarChartLooksForMultipleUsers(startTimestamp: self.targetChartVM.startTimestamp!, endTimestamp: self.targetChartVM.endTimestamp!)
            })
            .disposed(by: chartDisposeBag)
    }
    
    private func buildDatasetsForMultipleUsers(fromAverageScoresBySessionPerUser scores: TargetChartVM.AverageScoresPerUserBySession,
                                               withSessionNameIndexes sessionNameIndexes: [String: Int],
                                               withUserCount userCount: Int) -> [BarChartDataSet] {
        var dataSets = [BarChartDataSet]()
        for (offset: indexOfUser, element: (key: user, value: averageScoresBySession)) in scores.enumerated() {
            var entries = buildEntriesForMultipleUsers(fromAverageScoresBySession: averageScoresBySession, withSessionNameIndexes: sessionNameIndexes)
            
            let xOffset = -(1.0 / Double(userCount))/2.0 * (Double(userCount) - 1.0)
            self.moveXCoordinatesOfEntriesToMakeThemGrouped(&entries, numberOfUsers: userCount, indexOfUser: indexOfUser, xInterval: 1.0, xOffset: xOffset)
            
            let dataSet = BarChartDataSet(values: entries, label: user)
            dataSets.append(dataSet)
        }
        return dataSets
    }
    
    private func buildEntriesForMultipleUsers(fromAverageScoresBySession scores: [(String, Float)],
                                              withSessionNameIndexes sessionNameIndexes: [String: Int]) -> [BarChartDataEntry] {
        var entries = [BarChartDataEntry]()
        for (session, averageScore) in scores {
            let index = Double(sessionNameIndexes[session]!)
            let entry = BarChartDataEntry(x: index, y: Double(averageScore))
            entries.append(entry)
        }
        return entries
    }
    
    private func moveXCoordinatesOfEntriesToMakeThemGrouped(_ entries: inout [BarChartDataEntry], numberOfUsers m: Int, indexOfUser j: Int,  xInterval interval: Double, xOffset: Double) {
        var xDeltas = [Double]()
        for i in 0..<m {
            xDeltas.append((Double(i) * interval) / Double(m))
        }
        for entry in entries {
            entry.x += xDeltas[j] + xOffset
        }
    }
    
    private func setColorsForDatasetsForMultipleUsers(_ dataSets: inout [BarChartDataSet]) {
        for (i, dataSet) in dataSets.enumerated() {
            if dataSets.count > self.colors.count {
                for _ in colors.count-1..<dataSets.count {
                    colors.append(UIColor.random())
                }
            }
            dataSet.colors = [self.colors[i]]
        }
    }
    
    private func refreshDataForMultipleUsers(_ dataSets: [BarChartDataSet],
                                         withUserCount userCount: Int) {
        let data = BarChartData(dataSets: dataSets)
        data.barWidth = data.barWidth / Double(userCount)
        self.barChart.data = data
    }
    
    private func refreshBarchartForSingleUser(_ user: String) {
        targetChartVM.averageScoresForUserBySession(user)
            .subscribe(onNext: { [unowned self] averageScoresBySession in
                let entries = self.buildEntriesForSingleUser(fromAverageScoresBySession: averageScoresBySession)
                self.refreshBarchartDataForSingleUser(user, fromEntries: entries)
                self.refreshBarChartLooksForSingleUser(entries.count, startTimestamp: self.targetChartVM.startTimestamp!, endTimestamp: self.targetChartVM.endTimestamp!)
            })
            .disposed(by: chartDisposeBag)
    }
    
    private func buildEntriesForSingleUser(fromAverageScoresBySession scores: TargetChartVM.AverageScoresForUserBySession) -> [BarChartDataEntry] {
        var entries = [BarChartDataEntry]()
        for (i, val) in scores.enumerated() {
            let entry = BarChartDataEntry(x: Double(i), y: Double(val.1))
            entries.append(entry)
        }
        return entries
    }
    
    private func refreshBarchartDataForSingleUser(_ user: String, fromEntries entries: [BarChartDataEntry]) {
        // Each user should have a dataset, where the label is their name.
        let dataSet = BarChartDataSet(values: entries, label: user)
        dataSet.colors = [self.colors[0]]
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
    }
    
    private func refreshBarChartLooksForSingleUser(_ barCount: Int, startTimestamp start: Double, endTimestamp end: Double) {
        refreshBarChartLooksCommon(startTimestamp: start, endTimestamp: end)
        if barCount < 8 {
            barChart.data?.setDrawValues(true)
            barChart.leftAxis.drawGridLinesEnabled = false
            barChart.leftAxis.drawLabelsEnabled = false
            barChart.leftAxis.drawAxisLineEnabled = false
        } else {
            barChart.data?.setDrawValues(false)
            barChart.leftAxis.drawGridLinesEnabled = true
            barChart.leftAxis.drawLabelsEnabled = true
            barChart.leftAxis.drawAxisLineEnabled = true
        }
    }
    
    private func refreshBarChartLooksCommon(startTimestamp start: Double, endTimestamp end: Double) {
        barChart.chartDescription?.text = ""
        
        barChart.data?.setValueFont(UIFont(name: "Lato-Regular", size: 8)!)
        barChart.data?.setValueTextColor(UIColor(named: "ColorThemeDark")!)
        
        barChart.legend.textColor = UIColor(named: "ColorThemeDark")!
        barChart.legend.font = UIFont(name: "Lato-Regular", size: 10)!
        
        barChart.xAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        barChart.xAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        barChart.xAxis.labelPosition = .bottom
        
        barChart.xAxis.drawLabelsEnabled = true
        barChart.xAxis.axisMaxLabels = 2
        barChart.xAxis.granularity = 1.0
        barChart.xAxis.valueFormatter = TargetBarChartXAxisValueFormatter(startTimestamp: start, endTimestamp: end)
        barChart.xAxis.drawGridLinesEnabled = false
        
        barChart.leftAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        barChart.leftAxis.gridColor = UIColor(named: "ColorThemeMid")!
        barChart.leftAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        barChart.leftAxis.labelFont = UIFont(name: "Lato-Regular", size: 10)!
        
        barChart.rightAxis.drawGridLinesEnabled = false
        barChart.rightAxis.drawLabelsEnabled = false
        barChart.rightAxis.drawAxisLineEnabled = false
    }
    
    private func refreshBarChartLooksForMultipleUsers(startTimestamp start: Double, endTimestamp end: Double) {
        refreshBarChartLooksCommon(startTimestamp: start, endTimestamp: end)
        barChart.data?.setDrawValues(false)
        barChart.leftAxis.drawGridLinesEnabled = true
        barChart.leftAxis.drawLabelsEnabled = true
        barChart.leftAxis.drawAxisLineEnabled = true
    }
}

struct TargetBarChartDateProvider {
    
    func getDateStrings(forTimestamp timestamp: Double) -> String {
        let date = Date(timeIntervalSince1970: timestamp)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        return formatter.string(from: date)
    }
}

class TargetBarChartXAxisValueFormatter: IAxisValueFormatter {
    
    let dateProvider: TargetBarChartDateProvider
    let startTimestamp: Double
    let endTimestamp: Double
    
    init(startTimestamp: Double, endTimestamp: Double, dateProvider: TargetBarChartDateProvider = TargetBarChartDateProvider()) {
        self.dateProvider = dateProvider
        self.startTimestamp = startTimestamp
        self.endTimestamp = endTimestamp
    }

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let start = 0.0
        let entryCount = axis?.axisRange

        if value == start {
            return dateProvider.getDateStrings(forTimestamp: startTimestamp)
        } else if let entryCount = entryCount {
            let end = round(entryCount-1.0)
            if value == end {
                return dateProvider.getDateStrings(forTimestamp: endTimestamp)
            }
        }
        return ""
    }
}
