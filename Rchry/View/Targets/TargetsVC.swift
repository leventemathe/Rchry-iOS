//
//  TargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 11. 29..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class TargetsVC: UIViewController {

    @IBAction func newTargetBtnTouched(_ sender: UIBarButtonItem) {
        let newTargetVC = UIStoryboard(name: "NewTarget", bundle: nil).instantiateViewController(withIdentifier: "NewTargetVC")
        navigationController?.pushViewController(newTargetVC, animated: true)
    }
    
    @IBOutlet weak var targetsTableView: UITableView!
    
    let targetsVM = TargetsVM()
    private var disposeBag = DisposeBag()
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        targetsVM.targets
            .do(onNext: { [unowned self] (targets, error) in
                if let error = error {
                    MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: error, fromVC: self)
                }
            })
            .map { (targets, _) -> [Target] in
                targets == nil ? [Target]() : targets!
            }
            .bind(to: targetsTableView.rx.items(cellIdentifier: "TargetCell", cellType: TargetCell.self)) { _, target, cell in
                cell.update(icon: target.icon, name: target.name, distance: target.distance, preferredDistanceUnit: target.preferredDistanceUnit, scores: target.scores, shots: target.shots)
            }
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // To release Firebase listener
        disposeBag = DisposeBag()
    }
}
