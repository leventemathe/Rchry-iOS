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
    
    @IBOutlet weak var userPickerTextfield: UserPickerView!
    @IBOutlet weak var barChart: TargetBarChart!
    
    @IBOutlet weak var statsContainerStackView: UIStackView!
    @IBOutlet weak var averageLbl: UILabel!
    @IBOutlet weak var diffLbl: UILabel!
    @IBOutlet weak var maxLbl: UILabel!
    @IBOutlet weak var minLbl: UILabel!

    let disposeBag = DisposeBag()
    var guestDisposeBag: DisposeBag!
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        linkStreams()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBarchart()
        guestDisposeBag = DisposeBag()
        linkGuests()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guestDisposeBag = nil
    }
    
    private func setupBarchart() {
        barChart.setNoDataText(NSLocalizedString("No data", comment: "No data label for chart"))
        barChart.setGestures(false)
    }
    
    private func linkGuests() {
        userPickerTextfield.subscribeToGuests(targetChartVM.guests).disposed(by: guestDisposeBag)
    }
    
    private func linkStreams() {
        targetChartVM.subscribeToUser(userPickerTextfield.user).disposed(by: disposeBag)
        barChart.subscribe(targetChartVM.userScore, decimalPrecision: targetChartVM.decimalPrecision, minimumScore: targetChartVM.minimumScore).disposed(by: disposeBag)
        
        targetChartVM.average.bind(to: averageLbl.rx.text).disposed(by: disposeBag)
        targetChartVM.diff.bind(to: diffLbl.rx.text).disposed(by: disposeBag)
        targetChartVM.min.bind(to: minLbl.rx.text).disposed(by: disposeBag)
        targetChartVM.max.bind(to: maxLbl.rx.text).disposed(by: disposeBag)
    }
}
