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

class TargetsVC: UIViewController, StoryboardInstantiable {

    @IBAction func newTargetBtnTouched(_ sender: UIBarButtonItem) {
        navigationController?.pushViewController(NewTargetVC.instantiate(), animated: true)
    }
    
    @IBOutlet weak var targetsTableView: UITableView!
    
    let targetsVM = TargetsVM()
    private var networkingDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        removeEmptyCells()
        setupTargetTap()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeTargets()
    }
    
    private func removeEmptyCells() {
        targetsTableView.tableFooterView = UIView()
    }
    
    private func observeTargets() {
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
                cell.update(icon: target.icon, name: target.name, distance: target.distance, preferredDistanceUnit: target.preferredDistanceUnit, scores: target.scores)
            }
            .disposed(by: networkingDisposeBag)
    }
    
    private func setupTargetTap() {
        targetsTableView.rx.itemSelected.asObservable()
            .subscribe(onNext: { [unowned self] indexpath in
                let targetVC = TargetVC.instantiate()
                let target = self.targetsVM.targetsArray[indexpath.item]
                targetVC.targetVM = TargetVM(target: target)
                self.navigationController?.pushViewController(targetVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // To release Firebase listener
        networkingDisposeBag = DisposeBag()
    }
}
