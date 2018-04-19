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
    // Chart and picker views should be refreshed with new data whenever the vc
    private var pickerDisposeBag: DisposeBag!
    private var chartDisposeBag: DisposeBag!
    
    private let colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupBarChartNoDataText()
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
    
    private func createLabelForUserPicker(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "ColorThemeDark")
        label.textAlignment = .center
        label.font = UIFont(name: "Lato-Regular", size: 18)
        return label
    }
    
    private func setupUserPickerTextField(_ userPicker: UIPickerView) {
        userPickerTextfield.text = ShotNames.MY_SCORE
        userPickerTextfield.inputView = userPicker
    }
    
    @objc private func dismissUserPickerView() {
        view.endEditing(true)
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
                
                
                // Because not all users take part in all sessions,
                // the indexes for the entries will be off.
                // Because of this, I assign indexes to the session names,
                // that way sessions where the user didn't participate, can be skipped.
                let thisUsersScoresTookPartInAllSessions = averageScoreBySessionByUser.max(by: { $0.value.count < $1.value.count })!.value
                let sessionNames = thisUsersScoresTookPartInAllSessions.map { $0.0 }
                var sessionNameIndexes = [String: Int]()
                var index = 0
                for sessionName in sessionNames {
                    sessionNameIndexes[sessionName] = index
                    index += 1
                }
                
                // Build data sets
                var dataSets = [BarChartDataSet]()
                for (offset: indexOfUser, element: (key: user, value: averageScoresBySession)) in averageScoreBySessionByUser.enumerated() {
                    var entries = [BarChartDataEntry]()
                    for (session, averageScore) in averageScoresBySession {
                        let index = Double(sessionNameIndexes[session]!)
                        let entry = BarChartDataEntry(x: index, y: Double(averageScore))
                        entries.append(entry)
                    }
                    let xOffset = -(1.0 / Double(averageScoreBySessionByUser.count))/2.0 * Double(averageScoreBySessionByUser.count - 1)
                    self.groupEntries(&entries, numberOfUsers: averageScoreBySessionByUser.count, indexOfUser: indexOfUser, xInterval: 1.0, xOffset: xOffset)
                    let dataSet = BarChartDataSet(values: entries, label: user)
                    dataSets.append(dataSet)
                }
                
                // Color data sets
                for (i, dataSet) in dataSets.enumerated() {
                    if dataSets.count <= self.colors.count {
                        dataSet.colors = [self.colors[i]]
                    } else {
                        // TODO
                    }
                }
                
                // Set data
                let data = BarChartData(dataSets: dataSets)
                data.barWidth = data.barWidth / Double(averageScoreBySessionByUser.count)
                self.barChart.data = data
                self.refreshBarChartLooksForMultipleUsers()
            })
            .disposed(by: chartDisposeBag)
    }
    
    private func groupEntries(_ entries: inout [BarChartDataEntry], numberOfUsers m: Int, indexOfUser j: Int,  xInterval interval: Double, xOffset: Double) {
        var xDeltas = [Double]()
        for i in 0..<m {
            xDeltas.append((Double(i) * interval) / Double(m))
        }
        print(xDeltas)
        
        for entry in entries {
            entry.x += xDeltas[j] + xOffset
        }
        print(entries)
    }
    
    private func refreshBarchartForSingleUser(_ user: String) {
        targetChartVM.averageScoresForUserBySession(user)
            .subscribe(onNext: { [unowned self] averageScoresBySession in
                var entries = [BarChartDataEntry]()
                var sessionNames = [String]()
                for (i, val) in averageScoresBySession.enumerated() {
                    let entry = BarChartDataEntry(x: Double(i), y: Double(val.1))
                    entries.append(entry)
                    sessionNames.append(val.0)
                }
                self.refreshBarchartDataForSingleUser(user, fromEntries: entries)
                self.refreshBarChartLooksForSingleUser(sessionNames)
            })
            .disposed(by: chartDisposeBag)
    }
    
    private func refreshBarchartDataForSingleUser(_ user: String, fromEntries entries: [BarChartDataEntry]) {
        // Each user should have a dataset, where the label is their name.
        let dataSet = BarChartDataSet(values: entries, label: user)
        dataSet.colors = [self.colors[0]]
        let data = BarChartData(dataSets: [dataSet])
        barChart.data = data
    }
    
    private func refreshBarChartLooksForSingleUser(_ xStrings: [String]) {
        let formatter = TargetBarChartFormatter(xStrings)
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        barChart.xAxis.valueFormatter = xAxis.valueFormatter
        
        if xStrings.count > 4 {
            barChart.xAxis.drawLabelsEnabled = false
        } else {
            barChart.xAxis.drawLabelsEnabled = true
            barChart.xAxis.setLabelCount(xStrings.count, force: false)
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
    
    private func refreshBarChartLooksForMultipleUsers() {
        barChart.xAxis.valueFormatter = nil
        
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
