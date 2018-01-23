//
//  NewSessionVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 23..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import LMViews
import RxCocoa
import RxSwift

class NewSessionVC: UIViewController {

    @IBOutlet weak var guestPickerViews: UIStackView!
    @IBOutlet weak var availableGuestsCollectionView: UICollectionView!
    @IBOutlet weak var guestTextfield: LMTextField!
    @IBOutlet weak var addGuestBtn: LMButton!
    @IBOutlet weak var addedGuestsCollectionView: UICollectionView!
    @IBOutlet weak var nameTextfield: LMTextField!
    @IBOutlet weak var startBtn: LMButton!
    
    var newSessionVM: NewSessionVM!
    
    private let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        hideKeyboardWhenTappedAround()
        setupNewTargetVM()
        setupAddedGuestsCollectionView()
    }
    
    private func setupNewTargetVM() {
        let newGuestAdded = addGuestBtn.rx.tap.asObservable()
            .withLatestFrom(guestTextfield.rx.text.asObservable())
            .filter { $0 != nil }
            .map { $0!.trimmingCharacters(in: .whitespaces) }
            .filter { $0 != ""}
        let addedGuestRemoved = addedGuestsCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
        newSessionVM = NewSessionVM(newGuestAdded: newGuestAdded, addedGuestRemoved: addedGuestRemoved)
    }
    
    private func setupAddedGuestsCollectionView() {
        newSessionVM.guestsDatasource.asObservable()
            .bind(to: addedGuestsCollectionView.rx.items(cellIdentifier: "AddedGuestCell", cellType: GuestCell.self)) { _, guest, cell in
                cell.update(name: guest)
            }
            .disposed(by: disposeBag)
    }
}

