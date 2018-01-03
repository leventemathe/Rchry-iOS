//
//  NewTargetVM.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 03..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import Foundation

struct NewTargetVM {
    
    let scoresSubVM: ScoresSubVM
    let pickAnIconSubVM: PickAnIconSubVM
    
    init(scoresSubVM: ScoresSubVM = ScoresSubVM(), pickAnIconSubVM: PickAnIconSubVM = PickAnIconSubVM()) {
        self.scoresSubVM = scoresSubVM
        self.pickAnIconSubVM = pickAnIconSubVM
    }
}
