//
//  TargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews
import RxCocoa
import RxSwift
import Charts

class TargetVC: UIViewController, StoryboardInstantiable {

    @IBOutlet weak var newSessionBtn: LMButton!
    
    var targetVM: TargetVM!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavbarTitle(targetVM.buildTitle())
        setupNewSessionBtn()
    }
    
    private func setNavbarTitle(_ title: String) {
        navigationItem.title = title
    }
    
    private func setupNewSessionBtn() {
        newSessionBtn.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                self.pushNewSessionScreen()
            })
            .disposed(by: disposeBag)
    }
    
    private func pushNewSessionScreen() {
        let newSessionVC = NewSessionVC.instantiate()
        let newSessionVM = NewSessionVM(ownerTarget: self.targetVM.target)
        newSessionVC.newSessionVM = newSessionVM
        navigationController?.pushViewController(newSessionVC, animated: true)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let chartVC = segue.destination as? TargetChartVC {
            chartVC.targetChartVM = TargetChartVM(target: targetVM.target)
        }
    }
}
