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

    private var _tap = PublishSubject<Int>()
    
    var disposeBag: DisposeBag!
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupGestureRecognizer()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupGestureRecognizer()
    }
    
    private func setupGestureRecognizer() {
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(gestureTapped))
        addGestureRecognizer(tapGestureRecognizer)
    }
    
    func update(_ index: Int, title: String) {
        self.index = index
        titleLbl.text = title
        
        disposeBag = DisposeBag()
    }
    
    @objc func gestureTapped() {
        _tap.onNext(index)
    }
    
    var tapped: Observable<Int> {
        return _tap.asObserver()
    }
}
