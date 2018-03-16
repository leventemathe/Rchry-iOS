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
    
    private let _index: Variable<Int>
    private let _owner: Variable<String>
    
    private let _scores: [Float]
    private var _selectedScoreIndex = Variable<Int?>(nil)
    
    private var _scoreByUserAndIndex: Observable<(Float, String, Int)>!
    
    private let disposeBag = DisposeBag()
    
    init(index: Int, owner: String, scores: [Float], score: Float?) {
        _index = Variable(index)
        _owner = Variable(owner)
        _scores = scores
        var skip = 0
        if let score = score {
            _selectedScoreIndex.value = _scores.index(of: score)
            skip += 1
        }
        
        setupScoreSetterByUserAndIndex(withSkip: skip)
    }
    
    var index: Int {
        return _index.value
    }
    
    var owner: Observable<String> {
        return _owner.asObservable()
    }
    
    var scoresDataSource: Observable<[Float]> {
        return Observable.just(_scores)
    }
    
    var selectedItemIndexObservable: Observable<Int?> {
        return _selectedScoreIndex.asObservable()
    }
    
    var selectedItemIndex: Int? {
        return _selectedScoreIndex.value
    }
    
    func selectItemAtIndex(reactingTo observable: Observable<Int>) {
        observable.bind(to: _selectedScoreIndex).disposed(by: disposeBag)
    }
    
    // The skip here is either 1 or 0.
    // It's needed because I only want to send the event when the score actually changed.
    // If the cell attached to this vm is a reused cell, it means it already has a score set.
    // I don't want to send that, so I set the skip to 1.
    private func setupScoreSetterByUserAndIndex(withSkip skip: Int) {
        let score = selectedItemIndexObservable
            .skip(skip)
            .filter { $0 != nil }
            .map { $0! }
            .map { [unowned self] in self._scores[$0] }
        _scoreByUserAndIndex = Observable.combineLatest(score, owner.asObservable(), _index.asObservable(), resultSelector: { score, owner, index in
            return (score, owner, index)
        })
    }
    
    var scoreByUserAndIndex: Observable<(Float, String, Int)> {
        return _scoreByUserAndIndex
    }
}
