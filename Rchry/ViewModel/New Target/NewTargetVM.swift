//
//  NewTargetVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation
import RxSwift

struct NewTargetVM {
    
    let scoresSubVM: ScoresSubVM
    let pickAnIconSubVM: PickAnIconSubVM
    
    private let targetService: TargetService
    private let disposeBag = DisposeBag()
    
    init(targetService: TargetService = FirebaseTargetService(), scoresSubVM: ScoresSubVM = ScoresSubVM(), pickAnIconSubVM: PickAnIconSubVM = PickAnIconSubVM()) {
        self.targetService = targetService
        self.scoresSubVM = scoresSubVM
        self.pickAnIconSubVM = pickAnIconSubVM
    }
    
    func createTarget() {
        targetService.create(target: Target(name: "Target", distance: 15.2, scores: [0, 5, 8, 10, 11], icon: "target", shots: 0)).subscribe(onError: { error in
            print("An error happened while creating target: \(error).")
        }, onCompleted: {
            print("Target succesfully created.")
        }).disposed(by: disposeBag)
    }
}
