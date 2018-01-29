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
    
    private var disposeBag = DisposeBag()
    
    func update(owner: String, scoresDatasource scores: [Float]) {
        ownerLbl.text = owner
        
        disposeBag = DisposeBag()
        Observable.just(scores).bind(to: scoresCollectionView.rx.items(cellIdentifier: "SessionScoreCell", cellType: SessionScoreCell.self)) { _, score, cell in
            if let scoreString = score.prettyString() {
                cell.update(scoreString)
            }
        }
        .disposed(by: disposeBag)
    }
}

