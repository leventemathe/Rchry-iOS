//
//  SessionVC.swift
//  Rchry
//
//  Created by Máthé Levente on 2018. 01. 24..
//  Copyright © 2018. Máthé Levente. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SessionVC: UIViewController {

    @IBOutlet weak var scoreSelectorTableView: UITableView!
    
    var sessionVM = SessionVM()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoresTableView()
    }
    
    private func setupScoresTableView() {
        let sessionDatasource = SessionScoreSelectorDatasource()
        sessionVM.scores.bind(to: scoreSelectorTableView.rx.items(dataSource: sessionDatasource)).disposed(by: disposeBag)
    }
}

class SessionScoreSelectorDatasource: NSObject, RxTableViewDataSourceType, UITableViewDataSource {
    
    typealias Element = [SessionSection]
    
    var sections = Element()
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let sessionSections):
            sections = sessionSections
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sections[section].scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionScoreSelectorCell") as! SessionScoreSelectorCell
        let owner = sections[indexPath.section].scores[indexPath.row].0
        // TODO: inject scores from vm
        let scores = Observable<[Float]>.just([0,5,8,10,11])
        cell.update(owner: owner, scoresDatasource: scores)
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section].numberOfShot
    }
}
