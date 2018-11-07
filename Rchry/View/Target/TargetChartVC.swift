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
    
    var targetChartVM: TargetChartVM!
    
    @IBOutlet weak var userPickerTextfield: UITextField!
    @IBOutlet weak var barChart: TargetBarChart!
    
    @IBOutlet weak var statsContainerStackView: UIStackView!
    @IBOutlet weak var averageLbl: UILabel!
    @IBOutlet weak var diffLbl: UILabel!
    @IBOutlet weak var maxLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!
    
    private var disposeBag = DisposeBag()
    
    // Chart and picker views should be refreshed with new data whenever the vc appears.
    private var pickerDisposeBag: DisposeBag!
    
    // Every time a different user is picked, I need to clear the subs to statistics for the old user.
    // Recreate this when changing user.
    private var statisticsDisposeBag: DisposeBag!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUserPickerViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        barChart.setNoDataText(NSLocalizedString("No data", comment: "No data label for chart"))
        barChart.setGestures(false)
        engage()
        refresh()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        disengage()
        super.viewWillDisappear(animated)
    }
    
    private func engage() {
        targetChartVM.engage()
        barChart.engage()
        pickerDisposeBag = DisposeBag()
        statisticsDisposeBag = DisposeBag()
    }
    
    private func disengage() {
        targetChartVM.disengage()
        barChart.disengage()
        pickerDisposeBag = nil
        statisticsDisposeBag = nil
    }
    
    private func refresh() {
        refreshUserPickerViews()
        refreshBarChart()
        refreshStatistics()
    }
    
    
    
    
    
    
    // MARK: ********* User Picker setup **********
    
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
        let doneButtonFont = UIFont(name: "Amatic-Bold", size: 26.0)!
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: doneButtonFont], for: .normal)
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: doneButtonFont], for: .selected)
        return doneButton
    }
    
    @objc private func dismissUserPickerView() {
        view.endEditing(true)
    }
    
    private func setupUserPickerTextField(_ userPicker: UIPickerView) {
        userPickerTextfield.text = ShotNames.MY_SCORE
        userPickerTextfield.inputView = userPicker
    }
    
    // MARK: ********* End of User Picker setup **********
    
    
    
    
    
    // MARK: Refresh user picker, chart, and statistics labels
    
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
        guard let user = userPickerTextfield.text else {
            return
        }
        let scores = targetChartVM.userScore(user)
        barChart.refreshBarchart(scores,
                                 user: user,
                                 decimalPrecision: targetChartVM.decimalPrecision,
                                 minimumScore: targetChartVM.minimumScore)
    }
    
    private func refreshStatistics() {
        if let user = userPickerTextfield.text {
            statisticsDisposeBag = nil
            statisticsDisposeBag = DisposeBag()
            
            targetChartVM.average(forUser: user).bind(to: averageLbl.rx.text).disposed(by: statisticsDisposeBag)
            targetChartVM.min(forUser: user).bind(to: minLbl.rx.text).disposed(by: statisticsDisposeBag)
            targetChartVM.max(forUser: user).bind(to: maxLbl.rx.text).disposed(by: statisticsDisposeBag)
            targetChartVM.diff(forUser: user).bind(to: diffLbl.rx.text).disposed(by: statisticsDisposeBag)
            
            targetChartVM.shouldHideStats(forUser: user).bind(to: statsContainerStackView.rx.isHidden).disposed(by: statisticsDisposeBag)
        }
    }
}
