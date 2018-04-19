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
    
    init(target: Target, sessionService: SessionService = FirebaseSessionService()) {
        self.target = target
        self.sessionService = sessionService
    }
    
    private func calculateAverageScore(_ scores: [Float]) -> Float {
        return (scores.reduce(0.0) { $0 + $1 }) / Float(scores.count)
    }
    
    func averageScoresForUserBySession(_ user: String) -> Observable<[(String, Float)]> {
        return sessionService.getSessions(underTarget: target)
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
    
    var averageScoresPerUserBySession: Observable<[String: [(String, Float)]]> {
        return sessionService.getSessions(underTarget: target)
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
}
