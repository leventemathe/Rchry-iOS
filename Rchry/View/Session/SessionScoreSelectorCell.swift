//
//  SessionScoreSelectorCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import RxSwift

class SessionScoreSelectorCell: UITableViewCell {
    
    @IBOutlet weak var ownerLbl: UILabel!
    @IBOutlet weak var scoresCollectionView: UICollectionView!
    
    // TODO: these should probably be in a vm
    private var owner = Variable("")
    private var scores = Variable([Float]())
    private var previousSelectedScoreIndex = Variable<Int?>(nil)
    private var selectedScoreIndex = Variable<Int?>(nil)
    
    private var disposeBag = DisposeBag()
    
    func update(owner: String, scoresDatasource scores: [Float]) {
        disposeBag = DisposeBag()
        setupOwnerLbl(owner)
        setupScoresDatasource(scores)
        setupScoreSelected()
    }
    
    private func setupOwnerLbl(_ owner: String) {
        self.owner.value = owner
        self.owner.asDriver().drive(ownerLbl.rx.text).disposed(by: disposeBag)
    }
    
    private func setupScoresDatasource(_ scores: [Float]) {
        self.scores.value = scores
        self.scores.asObservable().bind(to: scoresCollectionView.rx.items(cellIdentifier: "SessionScoreCell", cellType: SessionScoreCell.self)) { _, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func setupScoreSelected() {
        setupScoreSeletedInput()
        observeScoreSelected()
    }
    
    private func setupScoreSeletedInput() {
        scoresCollectionView.rx.itemSelected.asObservable()
            .do(onNext: { [unowned self] indexPath in
                self.previousSelectedScoreIndex.value = self.selectedScoreIndex.value
            })
            .map { $0.item }
            .bind(to: selectedScoreIndex)
            .disposed(by: disposeBag)
    }
    
    private func observeScoreSelected() {
        Observable.combineLatest(previousSelectedScoreIndex.asObservable(), selectedScoreIndex.asObservable(), resultSelector: { ($0, $1) })
            .filter { $0.1 != nil }
            .map { ($0.0, $0.1!) }
            .subscribe(onNext: { [unowned self] (prev, curr) in
                if let prev = prev, let prevCell = self.scoresCollectionView.cellForItem(at: IndexPath(item: prev, section: 0)) as? SessionScoreCell {
                    prevCell.setUnselected()
                }
                if let selectedCell = self.scoresCollectionView.cellForItem(at: IndexPath(item: curr, section: 0)) as? SessionScoreCell {
                    selectedCell.setSelected()
                }
            }).disposed(by: disposeBag)
    }
    
    var scoreSelected: Observable<(Float, String)> {
        return selectedScoreIndex.asObservable()
            .filter { $0 != nil }
            .map { $0! }
            .map { [unowned self] index in
                let score = self.scores.value[index]
                return (score, self.owner.value)
            }
    }
}

