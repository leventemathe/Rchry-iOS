//
//  TargetChartVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 04. 10..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import RxSwift

class TargetChartVM {
    
    private let target: Target
    private let sessionService: SessionService
    private var disposeBag: DisposeBag!
    
    init(target: Target, sessionService: SessionService = FirebaseSessionService()) {
        self.target = target
        self.sessionService = sessionService
        engage()
    }
    
    private var sessions = Variable([Session]())
    
    func engage() {
        disposeBag = DisposeBag()
        sessionService.getSessions(underTarget: target).bind(to: sessions).disposed(by: disposeBag)
    }
    
    func disengage() {
        disposeBag = nil
    }
    
    private func calculateAverageScore(_ scores: [Float]) -> Float {
        return (scores.reduce(0.0) { $0 + $1 }) / Float(scores.count)
    }
    
    typealias AverageScoresForUserBySession = [(String, Float)]
    
    func averageScoresForUserBySession(_ user: String) -> Observable<AverageScoresForUserBySession> {
        return sessions.asObservable()
            .filter { $0.count > 0 }
            .map { sessions in
                var averageScores = [(String, Float)]()
                for session in sessions {
                    if let scores = session.shotsByUser[user] {
                        averageScores.append((session.name, self.calculateAverageScore(scores)))
                    }
                }
                return averageScores
            }
    }
    
    var guests: Observable<[String]> {
        return sessionService.getGuests()
            .map { guests in
                var users = [ShotNames.MY_SCORE, ShotNames.ALL_SCORES]
                users.append(contentsOf: guests)
                return users
            }
    }
    
    typealias AverageScoresPerUserBySession = [String: [(String, Float)]]
    
    var averageScoresPerUserBySession: Observable<AverageScoresPerUserBySession> {
        return sessions.asObservable()
            .filter { $0.count > 0 }
            .map { [unowned self] sessions in
                var result = [String: [(String, Float)]]()
                for session in sessions {
                    for (user, scores) in session.shotsByUser {
                        let averageScore = self.calculateAverageScore(scores)
                        if result[user] == nil {
                            result[user] = [(String, Float)]()
                        }
                        result[user]?.append((session.name, averageScore))
                    }
                }
                return result
            }
    }
    
    var startTimestamp: Double? {
        if sessions.value.count < 1 {
            return nil
        }
        return sessions.value[0].timestamp
    }
    
    var endTimestamp: Double? {
        if sessions.value.count < 1 {
            return nil
        }
        return sessions.value.last?.timestamp
    }
    
    func sessionNameIndexes(fromAverageScoresBySessionPerUser scores: AverageScoresPerUserBySession) -> [String: Int] {
        let thisUsersScoresTookPartInAllSessions = scores.max(by: { $0.value.count < $1.value.count })!.value
        let sessionNames = thisUsersScoresTookPartInAllSessions.map { $0.0 }
        var sessionNameIndexes = [String: Int]()
        var index = 0
        for sessionName in sessionNames {
            sessionNameIndexes[sessionName] = index
            index += 1
        }
        return sessionNameIndexes
    }
}
