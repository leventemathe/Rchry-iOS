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
                var users = [ShotNames.MY_SCORE]
                users.append(contentsOf: guests)
                return users
            }
    }
    
    // TODO:
    // TODO: change the return type to match func name
    var averageScoresPerUserBySession: Observable<[String: [Float]]> {
        return sessionService.getSessions(underTarget: target)
            .map { sessions in
                var result = [String: [Float]]()
                for session in sessions {
                    session.shotsByUser.forEach {
                        if result[$0.key] == nil {
                            result[$0.key] = [Float]()
                        }
                        let average = self.calculateAverageScore($0.value)
                        result[$0.key]?.append(average)
                    }
                }
                return result
            }
    }
}
