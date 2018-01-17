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
        setupNameAndDistanceChecking()
        setupNewScoreAdding()
        setupScoresCollectionView()
        setupPickAnIconCollectionView()
        setupSelectedIconSource()
        setupCreateBtnText()
        setupCreateButtonEnabling()
        setupCreateBtnTouched()
    }

    override func viewDidAppear(_ animated: Bool) {
        setupAddingBorderToSelectedIcon()
    }
    
    private func setupNameAndDistanceChecking() {
        bindNameAndDistanceToVariables()
        bindExistsVariableToErrorLblIsHidden()
    }
    
    private func bindNameAndDistanceToVariables() {
        newTargetVM.bindInputName(fromObservable: nameTextField.rx.text.asObservable())
        newTargetVM.bindInputDistance(fromObservable: distanceTextField.rx.text.asObservable())
    }
    
    private func bindExistsVariableToErrorLblIsHidden() {
        newTargetVM.bindOutputTargetExists(toObserver: targetDistanceExistsErrorLbl.rx.isHidden.asObserver())
    }
    
    private func setupNewScoreAdding() {
        let tap = addScoreBtn.rx.tap
        let scoreText = scoresTextField.rx.text
        
        let scoreObservable = scoreText.asObservable()
            .filter({ $0 != nil && $0!.float() != nil })
            .map({ $0!.float()! })
            .flatMap({ Observable<Float>.just($0) })
        
        let tapWithScoreObservable = tap.asObservable()
            .withLatestFrom(scoreObservable)
        newTargetVM.bindInputNewScore(fromObservable: tapWithScoreObservable)
    }
    
    private func setupScoresCollectionView() {
        setupScoresCollectionViewDataSource()
        setupScoreTapped()
    }
    
    private func setupScoresCollectionViewDataSource() {
        let datasource = newTargetVM.outputScoresDatasource
        datasource.asObservable().bind(to: scoresCollectionView.rx.items(cellIdentifier: "ScoreCell", cellType: ScoreCell.self)) { row, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
            } else {
                cell.update("")
            }
            }.disposed(by: disposeBag)
    }
    
    private func setupScoreTapped() {
        let tapEventWithIndex = scoresCollectionView.rx.itemSelected
            .asObservable()
            .flatMap({ Observable<Int>.just($0.row) })
        newTargetVM.bindInputDeleteScore(fromObservable: tapEventWithIndex)
    }
    
    private func setupPickAnIconCollectionView() {
        setupPickAnIconCollectionViewDatasource()
    }
    
    private func setupPickAnIconCollectionViewDatasource() {
        let dataSource = newTargetVM.outputIcons
        dataSource.asObservable().bind(to: pickAnIconCollectionView.rx.items(cellIdentifier: "PickAnIconCell", cellType: PickAnIconCell.self)) { item, iconString, cell in
            if let image = UIImage(named: iconString) {
                cell.update(image)
            }
        }.disposed(by: disposeBag)
    }
    
    private func setupSelectedIconSource() {
        let tapEventWithImageName = pickAnIconCollectionView.rx.itemSelected
            .asObservable()
            .flatMap { Observable<Int>.just($0.row) }
        newTargetVM.bindInputIconSelected(fromObservable: tapEventWithImageName.asObservable())
    }
    
    private func setupAddingBorderToSelectedIcon() {
        newTargetVM.outputSelectedIcon
            .subscribe(onNext: { [unowned self] last, current in
                if let lastCell = self.pickAnIconCollectionView.cellForItem(at: IndexPath(item: last, section: 0)) as? PickAnIconCell {
                    lastCell.removeBorder()
                }
                if let currentCell = self.pickAnIconCollectionView.cellForItem(at: IndexPath(item: current, section: 0)) as? PickAnIconCell {
                    currentCell.addBorder()
                }
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    private func setupCreateBtnText() {
        createBtn.setTitle(CREATE_BTN_TEXT_ENABLED, for: .normal)
        createBtn.setTitle(CREATE_BTN_TEXT_DISABLED, for: .disabled)
    }
    
    private func setupCreateButtonEnabling() {
        let isTargetReadyDriver = newTargetVM.outputIsTargetReady.asDriver()
        let isEnabled = createBtn.rx.isEnabled.asObserver()
        isTargetReadyDriver.drive(isEnabled).disposed(by: disposeBag)
    }
    
    private func setupCreateBtnTouched() {
        
    }
}
