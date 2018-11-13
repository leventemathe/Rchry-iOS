//
//  SessionVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 25..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

// A session starts with 1 shot at index 0, called Shot 1.
// It doesn't have any scores selected.
// Then the user can select a score for himself and the guests.
// When every user has a score set, 2 things happen:
// 1. The shot turns ready (this can happen only once) -> the session vm subs to this, and creates a new shot with index + 1 (again, no scores selected)
// 2. The shot turns to active == false. -> The shot only shows the header in the ui.
// A shot can change its activenss by tapping the header. This shows/hides the scores.
class SessionVM {
    
    private let sessionService: SessionService
    private let shotService: ShotService
    private let dateProvider: DateProvider
    
    private let session: Session
    
    private var _shots = Variable([Shot]())
    private let disposeBag = DisposeBag()
    
    init(session: Session, shotService: ShotService = FirebaseShotService(), sessionService: SessionService = FirebaseSessionService(), dateProvider: DateProvider = BasicDateProvider()) {
        self.session = session
        self.dateProvider = dateProvider
        self.sessionService = sessionService
        self.shotService = shotService
        setupInitialShot()
    }
    
    private func setupInitialShot() {
        addShot(withIndex: 0)
    }
    
    func addShot(withIndex index: Int) {
        var scores = Shot.ScoresByUser()
        if session.shotsByUser.contains(where: { $0.0 == ShotNames.LOC_MY_SCORE }) {
            scores.append((ShotNames.LOC_MY_SCORE, nil))
        }
        scores = session.shotsByUser
            .filter{ $0.0 != ShotNames.LOC_MY_SCORE }
            .map { $0.0 }
            .reduce(into: scores, { scores, guest in
            scores.append((guest, nil))
        })
        _shots.value.append(Shot(index: index, scores: scores, active: true))
        subscribeToLatesShotsReadynessToAddNewShot()
        subscribeToNewScoreSelectedToUpdateService(_shots.value.count-1)
    }
    
    private func subscribeToLatesShotsReadynessToAddNewShot() {
        _shots.value[_shots.value.count - 1].shotReadyObservable
            .subscribe(onNext: { [unowned self] _ in
                self.addShot(withIndex: self._shots.value.count)
            })
            .disposed(by: disposeBag)
    }
    
    // Mark: Call this for every new Shot
    private func subscribeToNewScoreSelectedToUpdateService(_ index: Int) {
        _shots.value[index].scoreFilledForUserAndIndex
            .subscribe(onNext: { [unowned self] (score, user, index) in
                self.shotService.update(score: score, byUser: user, forIndex: index, inSession: self.session).subscribe().dispose()
            })
            .disposed(by: disposeBag)
    }
    
    var possibleScores: [Float] {
        return session.ownerTarget.scores
    }
    
    var shotsDatasource: Observable<[Shot]> {
        return _shots.asObservable()
    }
    
    // This is set by tapping the header -> hide/show scores by users
    func setShotActiveness(reactingTo observable: Observable<Int>, disposedBy disposeBag: DisposeBag? = nil) {
        observable
            .subscribe(onNext: { [unowned self] index in
                let oldShot = self._shots.value[index]
                if !oldShot.shotReady {
                    return
                }
                let newShot = Shot(index: oldShot.index, scores: oldShot.scores, active: !oldShot.active, shotReady: true)
                self._shots.value[index] = newShot
                self.subscribeToNewScoreSelectedToUpdateService(index)
            })
            .disposed(by: disposeBag ?? self.disposeBag)
    }
    
    // This is set by the user's score cell, when a new score is tapped
    func setScoreByUserAndIndex(reactingTo observable: Observable<(Float, String, Int)>, disposedBy disposeBag: DisposeBag? = nil)  {
        observable
            .subscribe(onNext: { [unowned self] scoreByUserAndIndex in
                let index = scoreByUserAndIndex.2
                let user = scoreByUserAndIndex.1
                let score: Float? = scoreByUserAndIndex.0
                
                self._shots.value[index].addScore(score, byUser: user)
            })
            .disposed(by: disposeBag ?? self.disposeBag)
    }
    
    var title: String {
        if session.name != "" {
            return session.name
        }
        let dateString = dateProvider.dateString(fromTimestamp: session.timestamp)
        return dateString
    }
    
    private let doneTextDone = NSLocalizedString("Done", comment: "The done button text in session indicating the scoring is done.")
    private let doneTextCancel = NSLocalizedString("Cancel", comment: "The done button text in session indicating the scoring is done, but no scores were added (cancel).")
    
    var doneText: Observable<String> {
        return _shots.asObservable()
            .map { $0.filter { $0.shotReady } }
            .map { [unowned self] in $0.count > 0 ? self.doneTextDone : self.doneTextCancel }
    }
    
    var isEmpty: Bool {
        return _shots.value.filter { $0.shotReady }.count < 1
    }
    
    func deleteSession() {
        sessionService.delete(session: session).subscribe().disposed(by: disposeBag)
    }
}






