//
//  TargetChartVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 10..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import RxSwift

struct UserScoreData {
    
    let scoresBySession: [(String, Float)]
    let startTimestamp: Double
    let endTimestamp: Double
}

class TargetChartVM {
    
    let decimalPrecision: Int
    
    private let target: Target
    private let sessionService: SessionService
    private let statistics: Statistics
    
    private var sessions = Variable([Session]())
    private var disposeBag: DisposeBag!
    
    init(decimalPrecision: Int = 2, target: Target, statistics: Statistics = Statistics(), sessionService: SessionService = FirebaseSessionService()) {
        self.decimalPrecision = decimalPrecision
        self.target = target
        self.sessionService = sessionService
        self.statistics = statistics
        engage()
    }
    
    func engage() {
        disposeBag = DisposeBag()
        sessionService.observeSessions(underTarget: target).bind(to: sessions).disposed(by: disposeBag)
    }
    
    func disengage() {
        disposeBag = nil
    }
    
    func userScore(_ user: String) -> Observable<UserScoreData> {
        return sessions.asObservable()
            .filter { $0.count > 0 }
            .map { self.getScoresPerSessionForUser(user, fromSessions: $0) }
    }
    
    private func getScoresPerSessionForUser(_ user: String, fromSessions sessions: [Session]) -> UserScoreData {
        var averageScores = [(String, Float)]()
        for session in sessions {
            if let scores = session.shotsByUser[user] {
                if scores.count > 0 {
                    averageScores.append((session.name, self.statistics.calculateAverage(scores)!))
                }
            }
        }
        return UserScoreData(scoresBySession: averageScores, startTimestamp: sessions.first?.timestamp ?? 0, endTimestamp: sessions.last?.timestamp ?? 0)
    }
    
    var guests: Observable<[String]> {
        return sessionService.observeGuests()
            .map { guests in
                var users = [ShotNames.MY_SCORE]
                if guests.count > 0 {
                    users.append(contentsOf: guests)
                }
                return users
            }
    }
    
    private func scoresForUser(_ user: String) -> Observable<[Float]> {
        return sessions.asObservable()
            .map { [unowned self] in self.getScoresPerSessionForUser(user, fromSessions: $0) }
            .map { $0.scoresBySession }
            .filter { $0.count > 0 }
            .map { $0.map { $0.1 } }
    }
    
    func average(forUser user: String) -> Observable<String> {
        return scoresForUser(user)
            .map { [unowned self] in self.statistics.calculateAverage($0)! }
            .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    func min(forUser user: String) -> Observable<String> {
        return scoresForUser(user).map { [unowned self] in self.statistics.calculateMin($0)! }
        .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    func max(forUser user: String) -> Observable<String> {
        return scoresForUser(user).map { [unowned self] in self.statistics.calculateMax($0)! }
        .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    func diff(forUser user: String) -> Observable<String> {
        return scoresForUser(user).map { [unowned self] in self.statistics.calculateDiff($0)! }
        .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    var minimumScore: Float {
        return target.scores.min()!
    }
    
    var maximumScore: Float {
        return target.scores.max()!
    }
    
    func shouldHideStats(forUser user: String) -> Observable<Bool> {
        return sessions.asObservable()
            .map { [unowned self] in self.getScoresPerSessionForUser(user, fromSessions: $0) }
            .map { $0.scoresBySession.map { $0.1 } }
            .map { $0.count < 1 }
    }
}
