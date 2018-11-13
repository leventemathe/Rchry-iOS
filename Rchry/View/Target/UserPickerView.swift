//
//  UserPickerView.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 11. 12..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import LMViews
import RxCocoa
import RxSwift

class UserPickerView: LMTextField {
    
    private let disposeBag = DisposeBag()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let userPicker = createUserPickerView()
        setupUserPickerTextField(userPicker)
    }
    
    private func createUserPickerView() -> UIPickerView {
        let userPicker = UIPickerView()
        userPicker.backgroundColor = UIColor.white
        addToolbarToUserPicker()
        
        userPicker.rx.modelSelected(String.self)
            .map { $0[0] }
            .bind(to: self.rx.text)
            .disposed(by: disposeBag)
        
        return userPicker
    }
    
    private func addToolbarToUserPicker() {
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        toolbar.barTintColor = UIColor(named: "ColorThemeMid")
        
        toolbar.setItems([createDoneButtonForToolbar()], animated: false)
        toolbar.isUserInteractionEnabled = true
        
        self.inputAccessoryView = toolbar
    }
    
    private func createDoneButtonForToolbar() -> UIBarButtonItem {
        let doneButtonText = NSLocalizedString("Done", comment: "The user selected a target, and they press this button to leave the selector view.")
        let doneButton = UIBarButtonItem(title: doneButtonText, style: .done, target: self, action: #selector(UserPickerView.dismissUserPickerView))
        doneButton.tintColor = UIColor.white
        let doneButtonFont = UIFont(name: "Amatic-Bold", size: 26.0)!
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: doneButtonFont], for: .normal)
        doneButton.setTitleTextAttributes([NSAttributedString.Key.font: doneButtonFont], for: .selected)
        return doneButton
    }
    
    @objc private func dismissUserPickerView() {
        endEditing(true)
    }
    
    private func setupUserPickerTextField(_ userPicker: UIPickerView) {
        self.text = ShotNames.MY_SCORE
        self.inputView = userPicker
    }
    
    var user: Observable<String> {
        return self.rx.text.asObservable().filter { $0 != nil }.map { $0! }
    }
    
    func subscribeToGuests(_ guests: Observable<[String]>) -> Disposable {
        let pickerView = self.inputView as! UIPickerView
        return guests
            .bind(to: pickerView.rx.items) { [unowned self] row, element, view in
                var label: UILabel!
                if let view = view as? UILabel {
                    label = view
                }
                label = self.createLabelForUserPicker(element)
                return label
            }
    }
    
    private func createLabelForUserPicker(_ text: String) -> UILabel {
        let label = UILabel()
        label.text = text
        label.textColor = UIColor(named: "ColorThemeDark")
        label.textAlignment = .center
        label.font = UIFont(name: "Lato-Regular", size: 18)
        return label
    }
}
