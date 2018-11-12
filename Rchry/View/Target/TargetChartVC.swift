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

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupBarchart()
        linkStreams()
    }
    
    private func setupBarchart() {
        barChart.setNoDataText(NSLocalizedString("No data", comment: "No data label for chart"))
        barChart.setGestures(false)
    }
    
    private func linkStreams() {
        userPickerTextfield.subscribeToGuests(targetChartVM.guests)
        targetChartVM.subscribeToUser(userPickerTextfield.user)
        barChart.subscribe(targetChartVM.userScore, decimalPrecision: targetChartVM.decimalPrecision, minimumScore: targetChartVM.minimumScore)
    }
}
