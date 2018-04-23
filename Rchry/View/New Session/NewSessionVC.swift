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
    
    @IBOutlet weak var trackMyScoreCheckBox: CheckBox!
    
    @IBOutlet weak var nameTextfield: LMTextField!
    
    @IBOutlet weak var startBtn: LMButton!
    
    // This needs to be set when the vc is created, outside of the vc
    var ownerTarget: Target!
    // This is set in viewDidLoad
    var newSessionVM: NewSessionVM!
    
    private let disposeBag = DisposeBag()
    // Separate dispose bag to empty in viewWillDisappear to clean up Firebase observer
    private var networkDisposeBag = DisposeBag()
    
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
            .do(onNext: { [unowned self] _ in self.guestTextfield.text = "" })
        
        let availableGuestAdded = availableGuestsCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
            .map { [unowned self] in self.newSessionVM.savedGuestsArray[$0] }
        
        let addedGuestRemoved = addedGuestsCollectionView.rx.itemSelected.asObservable()
            .map { $0.item }
        
        let nameChanged = nameTextfield.rx.text.asObservable().filter{ $0 != nil }.map { $0! }
        
        let userTrackingChanged = trackMyScoreCheckBox.rxIsChecked
        
        newSessionVM = NewSessionVM(ownerTarget: ownerTarget,
                                    newGuestAdded: newGuestAdded,
                                    availableGuestAdded: availableGuestAdded,
                                    guestRemoved: addedGuestRemoved,
                                    nameChanged: nameChanged,
                                    userTrackingChanged: userTrackingChanged)
    }
    
    private func setupAddedGuestsCollectionView() {
        newSessionVM.guestsDatasource.asObservable()
            .bind(to: addedGuestsCollectionView.rx.items(cellIdentifier: "AddedGuestCell", cellType: GuestCell.self)) { _, guest, cell in
                cell.update(name: guest)
            }
            .disposed(by: disposeBag)
    }
    
    private func setupStartButton() {
        setupStartButtonReadyness()
        setupStartButtonTitle()
        setupStartButtonTapped()
    }
    
    private func setupStartButtonReadyness() {
        newSessionVM.isFormReady.bind(to: startBtn.rx.isEnabled).disposed(by: disposeBag)
    }
    
    private func setupStartButtonTitle() {
        startBtn.setTitle(NewSessionVC.NEW_SESSION_START_BUTTON_DISABLED, for: .disabled)
        startBtn.setTitle(NewSessionVC.NEW_SESSION_START_BUTTON_ENABLED, for: .normal)
    }
    
    private func setupStartButtonTapped() {
        let tapWithShouldTrackMyScore = startBtn.rx.tap.asObservable().withLatestFrom(trackMyScoreCheckBox.rxIsChecked)
        newSessionVM.createSession(reactingToShouldTrackMyScore: tapWithShouldTrackMyScore)
            .subscribe(onNext: { [unowned self] (session, error) in
                if let error = error {
                    MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: error, fromVC: self)
                } else if let session = session {
                    let storyboard = UIStoryboard(name: "Session", bundle: nil)
                    let sessionVC = storyboard.instantiateViewController(withIdentifier: "SessionVC") as! SessionVC
                    sessionVC.sessionVM = SessionVM(session: session)
                    self.navigationController?.pushViewController(sessionVC, animated: true)
                } else {
                    MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: CommonMessages.UNKOWN_ERROR, fromVC: self)
                }
            })
            .disposed(by: disposeBag)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupSavedGuestsObserving()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        networkDisposeBag = DisposeBag()
    }
    
    private func setupSavedGuestsObserving() {
        newSessionVM.savedGuestsDatasource
            .do(onNext: { [unowned self] (guests, error) in
                if let error = error {
                    MessageAlertModalVC.present(withTitle: CommonMessages.ERROR_TITLE, withMessage: error, fromVC: self)
                    return
                }
                if guests != nil && guests!.count > 0 {
                    self.guestPickerViews.isHidden = false
                } else {
                    self.guestPickerViews.isHidden = true
                }
            })
            .map { (guests, _) -> [String] in
                return guests ?? [String]()
            }
            .bind(to: availableGuestsCollectionView.rx.items(cellIdentifier: "GuestCell", cellType: GuestCell.self)) { _, guest, cell in
                cell.update(name: guest)
            }
            .disposed(by: networkDisposeBag)
    }
}

