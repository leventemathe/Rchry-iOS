//
//  CheckBox.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 20..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import RxSwift

class CheckBox: UIView {

    init() {
        super.init(frame: CGRect(x: 0, y: 0, width: 0, height: 0))
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    private let isChecked = Variable(true)
    
    private func setup() {
        setupBorder()
        setColor()
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(CheckBox.tapped(_:)))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    private func setupBorder() {
        layer.borderWidth = 2
        layer.cornerRadius = self.bounds.height / 2.0
    }
    
    @objc private func tapped(_ sender: UIGestureRecognizer) {
        swapState()
        setColor()
    }
    
    private func swapState() {
        isChecked.value = !isChecked.value
    }
    
    private func setColor() {
        layer.borderColor = UIColor(named: "ColorThemeMid")!.cgColor
        if !isChecked.value {
            backgroundColor = UIColor.white
        } else {
            backgroundColor = UIColor(named: "ColorThemeBright")!
        }
    }
    
    var rxIsChecked: Observable<Bool> {
        return isChecked.asObservable()
    }
}
