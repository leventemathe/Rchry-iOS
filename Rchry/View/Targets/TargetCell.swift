//
//  TargetCell.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 22..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews
import RxCocoa
import RxSwift

class TargetCell: UITableViewCell {

    @IBOutlet weak var iconImageView: LMImageView!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var distanceLbl: UILabel!
    @IBOutlet weak var scoresCollectionView: UICollectionView!
    
    // This should go to a viewmodel, and the vm should also have bindings for all the other ui elements
    // It's overcomplicated though, for a simple ui like this
    private var scoresDatasource = [Float]()
    private var disposeBag = DisposeBag()
    
    // TODO: These parameters should all be strings, and the conversions to string should happen in a viewmodel
    func update(icon: String, name: String, distance: Float, preferredDistanceUnit: DistanceUnit, scores: [Float]) {
        iconImageView.image = UIImage(named: icon)
        nameLbl.text = name
        if let distanceString = distance.prettyString() {
            distanceLbl.text = distanceString + " " + preferredDistanceUnit.toShortString()
        }
        scoresDatasource = scores
        disposeBag = DisposeBag()
        setupScoresDatasource()
    }
    
    private func setupScoresDatasource() {
        Observable.just(scoresDatasource)
            .bind(to: scoresCollectionView.rx.items(cellIdentifier: "TargetsScoreCell", cellType: ScoreCell.self)) { _, score, cell in
                if let scoreString = score.prettyString() {
                    cell.update(scoreString)
                }
            }
            .disposed(by: disposeBag)
    }
}
