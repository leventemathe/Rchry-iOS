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
    
    var targetChartVM: TargetChartVM!
    private var disposeBag = DisposeBag()
    // Chart and picker views should be refreshed with new data whenever the vc appears.
    private var pickerDisposeBag: DisposeBag!
    private var chartDisposeBag: DisposeBag!
    
    private let colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarChartNoDataText()
        setupbarChartGestures()
        setupUserPickerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        pickerDisposeBag = DisposeBag()
        chartDisposeBag = DisposeBag()
        refreshUserPickerViews()
        refreshBarChart()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
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
    
    private func refreshBarChart() {
        let userText = userPickerTextfield.rx.text.asObservable()
        userText
            .filter { $0 != nil }
            .map { $0! }
            .subscribe(onNext: { [unowned self] user in
                if user == ShotNames.ALL_SCORES {
                    self.refreshBarChartForAllUsers()
                } else {
                    self.refreshBarchartForSingleUser(user)
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
                self.refreshBarChartLooksForMultipleUsers()
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
            if dataSets.count <= self.colors.count {
                dataSet.colors = [self.colors[i]]
            } else {
                // TODO
            }
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
                self.refreshBarChartLooksForSingleUser()
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
    
    private func refreshBarChartLooksForSingleUser() {
        barChart.xAxis.drawLabelsEnabled = false
        
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
    
    private func refreshBarChartLooksForMultipleUsers() {
        barChart.xAxis.drawLabelsEnabled = false
        
        barChart.data?.setValueFont(UIFont(name: "Lato-Regular", size: 8)!)
        
        barChart.xAxis.drawLabelsEnabled = true
        
        barChart.xAxis.drawGridLinesEnabled = true
        barChart.xAxis.labelPosition = .bottom
        barChart.xAxis.axisLineColor = UIColor(named: "ColorThemeMid")!
        barChart.xAxis.labelTextColor = UIColor(named: "ColorThemeDark")!
        
        barChart.leftAxis.drawGridLinesEnabled = true
        barChart.leftAxis.drawLabelsEnabled = true
        barChart.leftAxis.drawAxisLineEnabled = true
        
        barChart.rightAxis.drawGridLinesEnabled = true
        barChart.rightAxis.drawLabelsEnabled = true
        barChart.rightAxis.drawAxisLineEnabled = true
        
        barChart.chartDescription?.text = ""
        
        barChart.legend.textColor = UIColor(named: "ColorThemeDark")!
        barChart.legend.font = UIFont(name: "Lato-Regular", size: 10)!
        barChart.data?.setValueTextColor(UIColor(named: "ColorThemeDark")!)
    }
}

