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

class TargetVC: UIViewController {

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
        let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
        let newSessionVC = storyboard.instantiateViewController(withIdentifier: "NewSessionVC") as! NewSessionVC
        newSessionVC.ownerTarget = self.targetVM.target
        navigationController?.pushViewController(newSessionVC, animated: true)
    }
}
