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
    
    static let NEW_SESSION_START_BUTTON_DISABLED = NSLocalizedString("NewSesseionStartButtonDisabled", comment: "The form is not filled yet, so the start button is disabled")
    static let NEW_SESSION_START_BUTTON_ENABLED = NSLocalizedString("NewSesseionStartButtonEnabled", comment: "The form is filled, so the start button is enabled")
    
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
        setupStartButton()
    }
    
    private func setupNewTargetVM() {
        let newGuestAdded = addGuestBtn.rx.tap.asObservable()
            .withLatestFrom(guestTextfield.rx.text.asObservable())
            .filter { $0 != nil }
            .map { $0! }
        
        let addedGuestRemoved = addedGuestsCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
        
        let nameChanged = nameTextfield.rx.text.asObservable().filter{ $0 != nil }.map { $0! }
        
        newSessionVM = NewSessionVM(newGuestAdded: newGuestAdded, addedGuestRemoved: addedGuestRemoved, nameChanged: nameChanged)
    }
    
    private func setupAddedGuestsCollectionView() {
        newSessionVM.guestsDatasource.asObservable()
            .bind(to: addedGuestsCollectionView.rx.items(cellIdentifier: "AddedGuestCell", cellType: GuestCell.self)) { _, guest, cell in
                cell.update(name: guest)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupStartButton() {
        startBtn.setTitle(NewSessionVC.NEW_SESSION_START_BUTTON_DISABLED, for: .disabled)
        startBtn.setTitle(NewSessionVC.NEW_SESSION_START_BUTTON_ENABLED, for: .normal)
        
        newSessionVM.isSessionReady.asDriver(onErrorJustReturn: false)
            .drive(startBtn.rx.isEnabled)
            .disposed(by: disposeBag)
    }
}

