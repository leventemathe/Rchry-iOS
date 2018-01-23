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

class TargetVC: UIViewController {

    @IBOutlet weak var newSessionBtn: LMButton!
    
    var targetVM: TargetVM!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavbarTitle(buildTitle())
        setupNewSessionBtn()
    }
    
    private func buildTitle() -> String {
        return targetVM.target.name +
                " " +
                (targetVM.target.distance.prettyString() ?? "") +
                " " +
                targetVM.target.preferredDistanceUnit.toShortString()
    }
    
    private func setNavbarTitle(_ title: String) {
        navigationItem.title = title
    }
    
    private func setupNewSessionBtn() {
        newSessionBtn.rx.tap.asObservable()
            .subscribe(onNext: { [unowned self] in
                let storyboard = UIStoryboard(name: "NewSession", bundle: nil)
                let newSessionVC = storyboard.instantiateViewController(withIdentifier: "NewSessionVC")
                self.navigationController?.pushViewController(newSessionVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
}
