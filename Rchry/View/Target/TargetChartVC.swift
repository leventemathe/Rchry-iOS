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
    
    private let colors = [UIColor(named: "ColorThemeBright")!, UIColor(named: "ColorThemeDark")!, UIColor(named: "ColorThemeMid")!, UIColor(named: "ColorThemeError")!]
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupUserPicking()
        setupBarChart()
    }
    
    private func setupUserPicking() {
        let userPicker = createUserPickerView()
        setupUserPickerTextField(userPicker)
    }
    
    private func createUserPickerView() -> UIPickerView {
        let userPicker = UIPickerView()
        userPicker.backgroundColor = UIColor.white
        addToolbarToUserPicker()
        
        targetChartVM.guests
            .bind(to: userPicker.rx.items) { [unowned self] row, element, view in
                var label: UILabel!
                if let view = view as? UILabel {
                    label = view
                }
                label = self.createLabelForUserPicker(element)
                return label
            }
            .disposed(by: disposeBag)
        
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
    
    private func setupBarChart() {
        setupBarChartNoDataText()
        // TODO: add logic to select user
        setupBarchartForSingleUser("my_score")
    }
    
    private func setupBarChartNoDataText() {
        barChart.noDataText = NSLocalizedString("TargetChartNoDataText", comment: "The text to display when there is no data yet for the chart for a target: average scores per session.")
        barChart.noDataTextColor = UIColor(named: "ColorThemeDark")!
        barChart.noDataFont = UIFont(name: "Amatic-Bold", size: 24)!
    }
    
    private func setupBarchartForSingleUser(_ user: String) {
        targetChartVM.averageScoresForUserBySession(user)
            .subscribe(onNext: { [unowned self] averageScoresBySession in
                var entries = [BarChartDataEntry]()
                var sessionNames = [String]()
                for (i, val) in averageScoresBySession.enumerated() {
                    let entry = BarChartDataEntry(x: Double(i), y: Double(val.1))
                    entries.append(entry)
                    sessionNames.append(val.0)
                }
                self.setupBarchartDataForSingleUser(user, fromEntries: entries)
                self.setupBarChartLooks(sessionNames)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupBarchartDataForSingleUser(_ user: String, fromEntries entries: [BarChartDataEntry]) {
        // Each user should have a dataset, where the label is their name.
        let dataSet = BarChartDataSet(values: entries, label: user)
        dataSet.colors = [self.colors[0]]
        let data = BarChartData(dataSets: [dataSet])
        self.barChart.data = data
    }
    
    private func setupBarChartLooks(_ xStrings: [String]) {
        let formatter = TargetBarChartFormatter(xStrings)
        let xAxis = XAxis()
        xAxis.valueFormatter = formatter
        barChart.xAxis.valueFormatter = xAxis.valueFormatter
        
        if xStrings.count > 4 {
            barChart.xAxis.drawLabelsEnabled = false
        } else {
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
