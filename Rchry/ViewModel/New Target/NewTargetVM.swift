//
//  NewTargetVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

class NewTargetVM {
    
    private let targetService: TargetService
    private let targetValidator: TargetValidator
    private let databaseErrorHandler: DatabaseErrorHandler
    private let distanceUnitConverter: DistanceUnitConverter
    
    var inputName = Variable("")
    var inputDistance = Variable<Float?>(nil)
    var inputDistanceUnit = Variable(DistanceUnit.meter)
    var inputNewScore = Variable<Float?>(nil)
    var inputDeletedScoreIndex = Variable<Int?>(nil)
    var inputCurrentSelectedIcon = Variable(0)
    
    private var _datasourceScores: Variable<[Float]>? = nil
    var datasourceScores: Observable<[Float]> {
        if _datasourceScores == nil {
            _datasourceScores = Variable([Float]())
            setupNewScore()
            setupDeleteScore()
        }
        return _datasourceScores!.asObservable()
    }
    
    private var _datasourceIcons = ["target", "deer", "bear", "ram", "wolf"]
    var datasourceIcons: Observable<[String]> {
        return Observable.just(_datasourceIcons)
    }
    
    private var _outputDoesTargetExist: Variable<Bool>?
    var outputDoesTargetExist: Observable<Bool> {
        if _outputDoesTargetExist == nil {
            _outputDoesTargetExist = Variable(false)
            setupDoesTargetExist()
        }
        return _outputDoesTargetExist!.asObservable()
    }
    
    private var _outputCurrentAndLastSelectedIcons: Variable<(Int, Int)>?
    var outputCurrentAndLastSelectedIcons: Observable<(Int, Int)> {
        if _outputCurrentAndLastSelectedIcons == nil {
            _outputCurrentAndLastSelectedIcons = Variable((inputCurrentSelectedIcon.value, inputCurrentSelectedIcon.value))
            setupOutputCurrentAndLastSelectedIcons()
        }
        return _outputCurrentAndLastSelectedIcons!.asObservable()
    }
    
    var outputIsTargetReady: Observable<Bool> {
        return Observable.combineLatest(inputName.asObservable(),
                                        inputDistance.asObservable(),
                                        datasourceScores.asObservable(),
                                        outputDoesTargetExist,
                                        resultSelector: {
            (name: $0, distance: $1, scores: $2, doesTargetExist: $3)
        })
            .map {
                $0.name != "" &&
                $0.distance != nil &&
                $0.scores.count > 0 &&
                !$0.doesTargetExist
            }
    }
    
    let disposeBag = DisposeBag()
    
    init(targetService: TargetService = FirebaseTargetService(),
         targetValidator: TargetValidator = TargetValidator(),
         databaseErrorHandler: DatabaseErrorHandler = BasicDatabaseErrorHandler(),
         distanceUnitConverter: DistanceUnitConverter = DistanceUnitConverter()) {
        self.targetService = targetService
        self.targetValidator = targetValidator
        self.databaseErrorHandler = databaseErrorHandler
        self.distanceUnitConverter = distanceUnitConverter
    }
    
    private func setupNewScore() {
        inputNewScore.asObservable()
            .filter { $0  != nil }
            .map { $0! }
            .subscribe(onNext: { [weak self] in
                self?._datasourceScores?.value.append($0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDeleteScore() {
        inputDeletedScoreIndex.asObservable()
            .filter { $0  != nil }
            .map { $0! }
            .subscribe(onNext: { [weak self] in
                self?._datasourceScores?.value.remove(at: $0)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupDoesTargetExist() {
        Observable<(String, Float?)>.combineLatest(inputName.asObservable(), inputDistance.asObservable(), resultSelector: {
            ($0, $1)
        })
            .filter { $0.1 != nil }
            .map { ($0, $1!) }
            .filter { $0.0 != "" }
            .debounce(0.25, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
                guard let this = self else { return }
                this.targetService.doesTargetExist(withName: $0.0, andWithDistance: $0.1)
                    .bind(to: this._outputDoesTargetExist!)
                    .disposed(by: this.disposeBag)
            })
            .disposed(by: disposeBag)
    }
    
    private func setupOutputCurrentAndLastSelectedIcons() {
        inputCurrentSelectedIcon.asObservable()
            .subscribe(onNext: { [weak self] in
                guard let this = self else { return }
                let lastSelected = this._outputCurrentAndLastSelectedIcons!.value.0
                let currentSelected = $0
                this._outputCurrentAndLastSelectedIcons?.value = (currentSelected, lastSelected)
            })
            .disposed(by: disposeBag)
        
    }
    
    func createTarget() -> Target {
        let distance = generateDistanceInMeters()
        return Target(name: inputName.value, distance: distance, scores: _datasourceScores!.value, icon: _datasourceIcons[inputCurrentSelectedIcon.value], shots: 0)
    }
    
    private func generateDistanceInMeters() -> Float {
        var distance = inputDistance.value!
        switch inputDistanceUnit.value {
        case .yard:
            distance = distanceUnitConverter.convertYardsToMeters(distance)
        case .meter:
            break
        }
        return distance
    }
}
