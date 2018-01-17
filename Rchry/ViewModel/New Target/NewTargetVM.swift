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
    
    var inputName = Variable("")
    var inputDistance = Variable("")
    var outputTargetExists = Variable(false)
    var inputDatasourceScores = Variable([Float]())
    var datasourceIcons = ["target", "deer", "bear", "ram", "wolf"]
    var inputOutputLastAndCurrentlySelectedIcon = Variable((0, 0))
    var outputIsTargetReady = Variable<Bool>(false)

    private let disposeBag = DisposeBag()
    
    init(targetService: TargetService = FirebaseTargetService(),
         targetValidator: TargetValidator = TargetValidator(),
         databaseErrorHandler: DatabaseErrorHandler = BasicDatabaseErrorHandler()) {
        self.targetService = targetService
        self.targetValidator = targetValidator
        self.databaseErrorHandler = databaseErrorHandler
        observeNameAndDistance()
        observeIsTargetReady()
    }
    
    private func observeNameAndDistance() {
        Observable<(name: String, distance: String)>.combineLatest(inputName.asObservable(), inputDistance.asObservable(), resultSelector: {
            (name: $0, distance: $1)
        })
        .filter({ $0.name != "" && $0.distance != "" })
        .debounce(0.3, scheduler: MainScheduler.instance)
            .subscribe(onNext: { [weak self] in
            self?.updateTargetExists(withName: $0.name, andWithDistance: $0.distance)
        }, onError: nil, onCompleted: nil)
        .disposed(by: disposeBag)
    }
    
    private func updateTargetExists(withName name: String, andWithDistance distance: String) {
        if let distanceFloat = distance.float() {
            let observable = targetService.doesTargetExist(withName: name, andWithDistance: distanceFloat)
            observable
                .subscribe(onNext: { [weak self] in self?.outputTargetExists.value = $0 }, onError: nil, onCompleted: nil, onDisposed: nil)
                .disposed(by: disposeBag)
        }
    }
    
    private func observeIsTargetReady() {
        Observable<(name: String, distance: String, scores: [Float])>.combineLatest(inputName.asObservable(), inputDistance.asObservable(), outputScoresDatasource, resultSelector: {
            (name: $0, distance: $1, scores: $2)
        })
        .map {
            $0.name != "" && $0.distance != "" && $0.scores.count > 0
        }
        .bind(to: outputIsTargetReady)
        .disposed(by: disposeBag)
    }
    
    func bindInputName(fromObservable observable: Observable<String?>) {
        observable
            .map({ return $0 == nil ? "" : $0!})
            .bind(to: inputName)
            .disposed(by: disposeBag)
    }
    
    func bindInputDistance(fromObservable observable: Observable<String?>) {
        observable
            .map({ return $0 == nil ? "" : $0!})
            .bind(to: inputDistance)
            .disposed(by: disposeBag)
    }
    
    func bindOutputTargetExists(toObserver observer: AnyObserver<Bool>) {
        outputTargetExists.asObservable()
            .map { !$0 }
            .bind(to: observer)
            .disposed(by: disposeBag)
    }
    
    func bindInputNewScore(fromObservable observable: Observable<Float>) {
        observable
            .filter { [weak self] in self != nil && !self!.inputDatasourceScores.value.contains($0) }
            .subscribe(onNext: { [weak self] in self?.inputDatasourceScores.value.append($0) }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    var outputScoresDatasource: Observable<[Float]> {
        return inputDatasourceScores.asObservable()
    }
    
    func bindInputDeleteScore(fromObservable observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [weak self] in self?.inputDatasourceScores.value.remove(at: $0) }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    var outputIcons: Observable<[String]> {
        return Observable.just(datasourceIcons)
    }
    
    func bindInputIconSelected(fromObservable observable: Observable<Int>) {
        observable
            .subscribe(onNext: { [weak self] currentlySelected in
                guard let this = self else {
                    return
                }
                let lastSelected = this.inputOutputLastAndCurrentlySelectedIcon.value.1
                this.inputOutputLastAndCurrentlySelectedIcon.value = (lastSelected, currentlySelected)
            }, onError: nil, onCompleted: nil, onDisposed: nil)
            .disposed(by: disposeBag)
    }
    
    var outputSelectedIcon: Observable<(Int, Int)> {
        return inputOutputLastAndCurrentlySelectedIcon.asObservable()
    }
    
    // TODO:
    func create(target: Target) -> Observable<String?> {
        switch targetValidator.validate(target: target) {
        case .success:
            return save(target: target)
        case .failure(let errorMessage):
            return Observable<String?>.just(errorMessage)
        }
    }
    
    private func save(target: Target) -> Observable<String?> {
        return Observable<String?>.create { [weak self] observer in
            self?.targetService.create(target: target).subscribe(onNext: nil, onError: { error in
                if let error = error as? DatabaseError {
                    observer.onNext(self?.databaseErrorHandler.handle(error: error))
                } else {
                    observer.onNext(self?.databaseErrorHandler.handle(error: DatabaseError.other))
                }
                observer.onCompleted()
            }, onCompleted: {
                observer.onCompleted()
            }, onDisposed: nil).disposed(by: self!.disposeBag)
            return Disposables.create()
        }
    }
}
