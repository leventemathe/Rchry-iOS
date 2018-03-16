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
    
    var sessionScoreSelectorVM: SessionScoreSelectorVM!
    
    var disposeBag = DisposeBag()
    
    func update(sessionScoreSelectorVM: SessionScoreSelectorVM) {
        disposeBag = DisposeBag()
        self.sessionScoreSelectorVM = sessionScoreSelectorVM
        setupOwnerLbl()
        setupScoresDatasource()
        setupObservingScoreSelection()
        setupReactingToTappingScore()
    }

    private func setupOwnerLbl() {
        sessionScoreSelectorVM.owner.bind(to: ownerLbl.rx.text).disposed(by: disposeBag)
    }
    
    private func setupScoresDatasource() {
        sessionScoreSelectorVM.scoresDataSource.bind(to: scoresCollectionView.rx.items(cellIdentifier: "SessionScoreCell", cellType: SessionScoreCell.self)) { [unowned self] index, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
                if self.sessionScoreSelectorVM.selectedItemIndex == nil || self.sessionScoreSelectorVM.selectedItemIndex! != index  {
                    cell.setUnselected()
                } else {
                    cell.setSelected()
                }
            }
        }
        .disposed(by: disposeBag)
    }
    
    private func setupObservingScoreSelection() {
        let skip = sessionScoreSelectorVM.selectedItemIndex == nil ? 0 : 1
        sessionScoreSelectorVM.selectedItemIndexObservable
            .skip(skip)
            .subscribe(onNext: { [unowned self] _ in
                self.scoresCollectionView.reloadData()
            })
            .disposed(by: disposeBag)
    }
    
    private func setupReactingToTappingScore() {
        let selected = scoresCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
        sessionScoreSelectorVM.selectItemAtIndex(reactingTo: selected)
    }
}

