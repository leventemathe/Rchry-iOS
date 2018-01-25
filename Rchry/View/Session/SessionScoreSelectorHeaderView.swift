//
//  SessionScoreSelectorHeaderView.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import RxSwift

class SessionScoreSelectorHeaderView: UIView {

    @IBOutlet weak var titleLbl: UILabel!
    
    private var index: Int!
    
    private let _tap = PublishSubject<Int>()
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupTap()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupTap()
    }
    
    private func setupTap() {
        let tap = UITapGestureRecognizer(target: self, action: #selector(SessionScoreSelectorHeaderView.tapped(_:)))
        addGestureRecognizer(tap)
    }
    
    func update(_ index: Int, title: String) {
        self.index = index
        titleLbl.text = title
    }
    
    @objc func tapped(_ gestureRecognizer: UITapGestureRecognizer) {
        _tap.onNext(index)
    }
    
    var tapped: Observable<Int> {
        return _tap.asObservable()
    }
}
