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
    
    private var index: Int!
    
    private var disposeBag = DisposeBag()
    
    func update(index: Int, owner: String, scoresDatasource scores: Observable<[Float]>) {
        self.index = index
        self.ownerLbl.text = owner
        disposeBag = DisposeBag()
        setupScoresDatasource(scores)
    }

    private func setupScoresDatasource(_ scores: Observable<[Float]>) {
        scores.bind(to: scoresCollectionView.rx.items(cellIdentifier: "SessionScoreCell", cellType: SessionScoreCell.self)) { _, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
            }
        }
        .disposed(by: disposeBag)
    }
}

