//
//  SessionScoreSelectorVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 03. 16..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class SessionScoreSelectorVM {
    
    let index: Int
    
    private var _owner: Variable<String>
    
    private var _scores: [Float]
    private var _selectedItem = Variable<Int?>(nil)
    
    private let disposeBag = DisposeBag()
    
    init(index: Int, owner: String, scores: [Float]) {
        self.index = index
        self._owner = Variable(owner)
        self._scores = scores
    }
    
    var owner: Observable<String> {
        return _owner.asObservable()
    }
    
    var scoresDataSource: Observable<[Float]> {
        return Observable.just(_scores)
    }
    
    var selectedItem: Observable<Int?> {
        return _selectedItem.asObservable()
    }
    
    var selectedItemIndex: Int? {
        return _selectedItem.value
    }
    
    func selectItem(reactingTo observable: Observable<Int>) {
        observable.bind(to: _selectedItem).disposed(by: disposeBag)
    }
}
