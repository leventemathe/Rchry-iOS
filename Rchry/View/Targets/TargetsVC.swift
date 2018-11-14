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
    
    var targetsVM = TargetsVM()
    
    private var networkingDisposeBag = DisposeBag()
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        targetsTableView.rx.setDelegate(self).disposed(by: disposeBag)
        removeEmptyCells()
        setupTargetTap()
        setupTargetSwipeToDelete()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeTargets()
    }
    
    private func removeEmptyCells() {
        targetsTableView.tableFooterView = UIView()
    }
    
    private func setupTargetTap() {
        targetsTableView.rx.modelSelected(Target.self)
            .subscribe(onNext: { [unowned self] target in
                let targetVC = TargetVC.instantiate()
                targetVC.targetVM = TargetVM(target: target)
                self.navigationController?.pushViewController(targetVC, animated: true)
            })
            .disposed(by: disposeBag)
    }
    
    // Handle delete events that are sent by the delegate
    private func setupTargetSwipeToDelete() {
        let deletedEvent = targetsTableView.rx.modelDeleted(Target.self)
        deletedEvent.subscribe {
            if let target = $0.element {
                self.targetsVM.delete(target)
            }
        }.disposed(by: disposeBag)
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
    
    override func viewWillDisappear(_ animated: Bool) {
        // To release Firebase listener
        networkingDisposeBag = DisposeBag()
    }
}

extension TargetsVC: UITableViewDelegate {
    
    // Send delete events by swiping
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteButton = UITableViewRowAction(style: .default, title: NSLocalizedString("Delete", comment: "Delete target on swiping")) { (action, indexPath) in
            let ds = self.targetsTableView.dataSource
            ds?.tableView!(self.targetsTableView, commit: .delete, forRowAt: indexPath)
            return
        }
        return [deleteButton]
    }
}
