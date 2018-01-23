//
//  NewTargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 12. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews
import RxCocoa
import RxSwift

class NewTargetVC: UIViewController {
    
    let CREATE_BTN_TEXT_ENABLED = NSLocalizedString("CreateTargetBtnTextEnabled", comment: "The text displayed on the create target button, when it's enabled")
    let CREATE_BTN_TEXT_DISABLED = NSLocalizedString("CreateTargetBtnTextDisabled", comment: "The text displayed on the create target button, when it's disabled")
    
    @IBOutlet weak var targetDistanceExistsErrorLbl: UILabel!
    @IBOutlet weak var nameTextField: LMTextField!
    @IBOutlet weak var distanceTextField: LMTextField!
    @IBOutlet weak var distanceUnitSelector: LMSegmentedControl!
    
    @IBOutlet weak var scoresTextField: LMTextField!
    @IBOutlet weak var addScoreBtn: LMButton!
    
    @IBOutlet weak var scoresCollectionView: UICollectionView!
    @IBOutlet weak var pickAnIconCollectionView: UICollectionView!
    
    @IBOutlet weak var createBtn: LMButton!
    
    var newTargetVM = NewTargetVM()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupCreateBtnLabelText()
        bindInput()
        bindInputOutput()
        bindDatasourcesFromVM()
        bindOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        // This has to go here, because the cells have to be visible to set the initial selection
        bindOutputCurrentAndLastSelectedIcons()
    }
    
    private func setupCreateBtnLabelText() {
        createBtn.setTitle(CREATE_BTN_TEXT_ENABLED, for: .normal)
        createBtn.setTitle(CREATE_BTN_TEXT_DISABLED, for: .disabled)
    }
    
    private func bindInput() {
        bindInputName()
        bindInputDistance()
        bindInputDistanceUnit()
        bindInputAddScore()
        bindInputDeleteScore()
        bindInputIconSelection()
    }
    
    private func bindInputName() {
        nameTextField.rx.text.asObservable()
            .map { $0 ?? "" }
            .bind(to: newTargetVM.inputName)
            .disposed(by: disposeBag)
    }
    
    private func bindInputDistance() {
        distanceTextField.rx.text.asObservable()
            .map { $0 ?? "" }
            .map { $0.float() }
            .bind(to: newTargetVM.inputDistance)
            .disposed(by: disposeBag)
    }
    
    private func bindInputDistanceUnit() {
        distanceUnitSelector.rx.value.asObservable()
            .map { $0 == 0 ? DistanceUnit.meter : DistanceUnit.yard }
            .bind(to: newTargetVM.inputDistanceUnit)
            .disposed(by: disposeBag)
    }
    
    private func bindInputAddScore() {
        addScoreBtn.rx.tap.asObservable()
            .withLatestFrom(scoresTextField.rx.text.asObservable())
            .map { $0 ?? "" }
            .map { $0.float() }
            .bind(to: newTargetVM.inputNewScore)
            .disposed(by: disposeBag)
    }
    
    private func bindInputDeleteScore() {
        scoresCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
            .bind(to: newTargetVM.inputDeletedScoreIndex)
            .disposed(by: disposeBag)
    }
    
    private func bindInputIconSelection() {
        pickAnIconCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
            .bind(to: newTargetVM.inputCurrentSelectedIcon)
            .disposed(by: disposeBag)
    }
    
    private func bindInputOutput() {
        bindInputOutputCreateTarget()
    }
    
    private func bindInputOutputCreateTarget() {
        newTargetVM.outputTargetCreated(reactingTo: createBtn.rx.tap.asObservable())
            .subscribe(onNext: { [weak self] (target, error) in
                if let error = error {
                    guard let this = self else { return }
                    MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: error, fromVC: this)
                } else {
                    self?.navigationController?.popViewController(animated: true)
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindDatasourcesFromVM() {
        bindDatasourceScores()
        bindDatasourceIcons()
    }
    
    private func bindDatasourceScores() {
        newTargetVM.datasourceScores.bind(to: scoresCollectionView.rx.items(cellIdentifier: "ScoreCell", cellType: ScoreCell.self)) { _, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func bindDatasourceIcons() {
        newTargetVM.datasourceIcons.bind(to: pickAnIconCollectionView.rx.items(cellIdentifier: "PickAnIconCell", cellType: PickAnIconCell.self)) { _, icon, cell in
            if let image = UIImage(named: icon) {
                cell.update(image)
            }
        }
        .disposed(by: disposeBag)
    }

    private func bindOutput() {
        bindOutputDoesTargetExist()
        bindOutputIsTargetReady()
    }
    
    private func bindOutputDoesTargetExist() {
        newTargetVM.outputDoesTargetExist.asDriver(onErrorJustReturn: false)
            .map { !$0 }
            .drive(targetDistanceExistsErrorLbl.rx.isHidden.asObserver())
            .disposed(by: disposeBag)
    }
    
    private func bindOutputCurrentAndLastSelectedIcons() {
        newTargetVM.outputCurrentAndLastSelectedIcons.asObservable()
            .subscribe(onNext: { [weak self] in
                let lastSelectedIndexPath = IndexPath(item: $0.1, section: 0)
                if let lastSelectedCell = self?.pickAnIconCollectionView.cellForItem(at: lastSelectedIndexPath) as? PickAnIconCell {
                    lastSelectedCell.removeBorder()
                }
                let currentSelectedIndexpath = IndexPath(item: $0.0, section: 0)
                if let currentSelectedCell = self?.pickAnIconCollectionView.cellForItem(at: currentSelectedIndexpath) as? PickAnIconCell {
                    currentSelectedCell.addBorder()
                }
            })
            .disposed(by: disposeBag)
    }
    
    private func bindOutputIsTargetReady() {
        newTargetVM.outputIsTargetReady.asDriver(onErrorJustReturn: false)
            .drive(createBtn.rx.isEnabled.asObserver())
            .disposed(by: disposeBag)
    }
}
