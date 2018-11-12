//
//  TargetChartVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 10..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import RxSwift

struct UserScoreData {
    
    let user: String
    let scoresBySession: [(String, Float)]
    let startTimestamp: Double
    let endTimestamp: Double
}

class TargetChartVM {
    
    let decimalPrecision: Int
    
    private let target: Target
    private let sessionService: SessionService
    private let statistics: Statistics
    
    private var user = Variable("my_score")
    private var disposeBag = DisposeBag()
    
    init(target: Target, decimalPrecision: Int = 2, statistics: Statistics = Statistics(), sessionService: SessionService = FirebaseSessionService()) {
        self.decimalPrecision = decimalPrecision
        self.target = target
        self.sessionService = sessionService
        self.statistics = statistics

    }
    
    func subscribeToUser(_ user: Observable<String>) {
        user.bind(to: self.user).disposed(by: disposeBag)
    }
    
    var userScore: Observable<UserScoreData> {
        return Observable.combineLatest(user.asObservable(), sessionService.observeSessions(underTarget: target), resultSelector: { user, sessions in
            var averageScores = [(String, Float)]()
            for session in sessions {
                if let scores = session.shotsByUser[user] {
                    if scores.count > 0 {
                        averageScores.append((session.name, self.statistics.calculateAverage(scores)!))
                    }
                }
            }
            return UserScoreData(user: user, scoresBySession: averageScores, startTimestamp: sessions.first?.timestamp ?? 0, endTimestamp: sessions.last?.timestamp ?? 0)
        }).asObservable()
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
    
    var average: Observable<String> {
        return userScore
            .map { [unowned self] in self.statistics.calculateAverage($0.scoresBySession.map { $0.1 })! }
            .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    var min: Observable<String> {
        return userScore
            .map { [unowned self] in self.statistics.calculateMin($0.scoresBySession.map { $0.1 })! }
            .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    var max: Observable<String> {
        return userScore
            .map { [unowned self] in self.statistics.calculateMax($0.scoresBySession.map { $0.1 })! }
            .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    var diff: Observable<String> {
        return userScore
            .map { [unowned self] in self.statistics.calculateDiff($0.scoresBySession.map { $0.1 })! }
            .map { $0.prettyString(minFractionDigits: self.decimalPrecision, maxFractionDigits: self.decimalPrecision)! }
    }
    
    var minimumScore: Float {
        return target.scores.min()!
    }
    
    var maximumScore: Float {
        return target.scores.max()!
    }
    
    var shouldHideStats: Observable<Bool> {
        return userScore
            .map { $0.scoresBySession }
            .map { $0.isEmpty }
    }
}
