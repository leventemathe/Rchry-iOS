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
                // TODO: because not all users take part in all sessions,
                // the indexes for the entries will be off.
                // Because of this, assign a indexes to the session names,
                // that way sessions where the user didn't participate, can be skipped.
                var dataSets = [BarChartDataSet]()
                for (user, averageScoresBySession) in averageScoreBySessionByUser {
                    var entries = [BarChartDataEntry]()
                    for (i, val) in averageScoresBySession.enumerated() {
                        let entry = BarChartDataEntry(x: Double(i), y: Double(val.1))
                        entries.append(entry)
                    }
                    let dataSet = BarChartDataSet(values: entries, label: user)
                    dataSets.append(dataSet)
                }
                for (i, dataSet) in dataSets.enumerated() {
                    if dataSets.count <= self.colors.count {
                        dataSet.colors = [self.colors[i]]
                    } else {
                        // TODO
                    }
                }
                let data = BarChartData(dataSets: dataSets)
                // The reason for these numbers:
                // The way BarChartData calculates group width: datasets.count * (barWidth + barSpace) + groupSpace.
                // In order for the group to fit on the x axis, this needs to be 1 (because we go from 0 to n on the x axis, by increments of 1).
                // So: 1 = datasets.count * (barWidth + barSpace) + groupSpace.
                // I set barSpace to 0, we know datasets.count, so we have to set the barWidth to fit the group into 1.
                let groupSpace = 0.5
                data.barWidth = (1-groupSpace) / Double(data.dataSets.count)
                data.groupBars(fromX: -groupSpace, groupSpace: groupSpace, barSpace: 0)
                
                self.barChart.data = data
                self.refreshBarChartLooksForMultipleUsers()
            })
            .disposed(by: chartDisposeBag)
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
