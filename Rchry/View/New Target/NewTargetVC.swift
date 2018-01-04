//
//  NewTargetVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2017. 12. 28..
//  Copyright © 2017. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews

class NewTargetVC: UIViewController {
    
    @IBOutlet weak var nameTextField: LMTextField!
    @IBOutlet weak var distanceTextField: LMTextField!
    @IBOutlet weak var scoresTextField: LMTextField!
    
    @IBOutlet weak var scoresCollectionView: UICollectionView!
    @IBOutlet weak var pickAnIconCollectionView: UICollectionView!
    
    var newTargetVM = NewTargetVM()
    
    private var scoresCollectionViewDelegate: ScoresCollectionViewDelegate!
    private var pickAnIconCollectionViewDelegate: PickAnIconCollectionViewDelegate!
    
    @IBAction func addScoreBtnTouched(_ sender: LMButton) {
        if let scoreString = scoresTextField.text, let score = Float(scoreString) {
            _ = newTargetVM.scoresSubVM.add(score: score)
            scoresCollectionView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        hideKeyboardWhenTappedAround()
        setupScoresCollectionView()
        setupPickAnIconCollectionView()
    }
    
    private func setupScoresCollectionView() {
        scoresCollectionViewDelegate = ScoresCollectionViewDelegate(scoresCollectionView, withScoresSubVM: newTargetVM.scoresSubVM)
        scoresCollectionView.delegate = scoresCollectionViewDelegate
        scoresCollectionView.dataSource = scoresCollectionViewDelegate
    }
    
    private func setupPickAnIconCollectionView() {
        pickAnIconCollectionViewDelegate = PickAnIconCollectionViewDelegate(pickAnIconCollectionView, withPickAnIconSubVM: newTargetVM.pickAnIconSubVM)
        pickAnIconCollectionView.delegate = pickAnIconCollectionViewDelegate
        pickAnIconCollectionView.dataSource = pickAnIconCollectionViewDelegate
    }
}

class ScoresCollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private weak var collectionView: UICollectionView!
    private var scoresVM: ScoresSubVM
    
    init(_ collectionView: UICollectionView, withScoresSubVM scoresVM: ScoresSubVM) {
        self.collectionView = collectionView
        self.scoresVM = scoresVM
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return scoresVM.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "ScoreCell", for: indexPath) as? ScoreCell {
            if let score = scoresVM[indexPath.row] {
                cell.update(String(score))
            }
            return cell
        }
        fatalError("Could not cast cell for item at ... as ScoreCell.")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let cell = collectionView.cellForItem(at: indexPath) as? ScoreCell, let scoreString = cell.scoreLbl.text, let score = Float(scoreString) {
            if scoresVM.remove(score: score) {
                collectionView.deleteItems(at: [indexPath])
            }
        }
    }
}

class PickAnIconCollectionViewDelegate: NSObject, UICollectionViewDelegate, UICollectionViewDataSource {
    
    private weak var collectionView: UICollectionView!
    private var pickAnIconVM: PickAnIconSubVM
    
    init(_ collectionView: UICollectionView, withPickAnIconSubVM pickAnIconVM: PickAnIconSubVM) {
        self.collectionView = collectionView
        self.pickAnIconVM = pickAnIconVM
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return pickAnIconVM.images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PickAnIconCell", for: indexPath) as? PickAnIconCell {
            if pickAnIconVM.isSelected(indexPath.row) {
                cell.addBorder()
            } else {
                cell.removeBorder()
            }
            cell.update(pickAnIconVM.images[indexPath.row])
            return cell
        }
        fatalError("Could not cast cell for item at ... as PickAnIconCell.")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if pickAnIconVM.isSelected(indexPath.row) {
            return
        }
        if let newSelectedCell = collectionView.cellForItem(at: indexPath) as? PickAnIconCell {
            if let selected = pickAnIconVM.selectedImage, let oldSelectedCell = collectionView.cellForItem(at: IndexPath(row: selected, section: 0)) as? PickAnIconCell {
                oldSelectedCell.removeBorder()
            }
            newSelectedCell.addBorder()
            pickAnIconVM.selectedImage = indexPath.row
            return
        }
        fatalError("Could not cast cell for item at ... as PickAnIconCell.")
    }
}
