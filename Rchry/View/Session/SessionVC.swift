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
        let sessionDatasource = SessionScoreSelectorDatasource(sessionVM: sessionVM)
        sessionVM.scores.bind(to: scoreSelectorTableView.rx.items(dataSource: sessionDatasource)).disposed(by: disposeBag)
        scoreSelectorTableView.rx.setDelegate(sessionDatasource).disposed(by: disposeBag)
    }
}

class SessionScoreSelectorDatasource: NSObject, RxTableViewDataSourceType, UITableViewDataSource, UITableViewDelegate {
    
    typealias Element = [SessionSection]

    private var sections = Element()
    
    private weak var sessionVM: SessionVM!
    
    private let disposeBag = DisposeBag()
    
    init(sessionVM: SessionVM) {
        self.sessionVM = sessionVM
    }
    
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
        return sections[section].scoresByUser.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionScoreSelectorCell") as! SessionScoreSelectorCell
        let owner = sections[indexPath.section].scoresByUser[indexPath.row].0
        // TODO: inject scores from vm
        let scores = Observable<[Float]>.just([0,5,8,10,11])
        cell.update(owner: owner, scoresDatasource: scores)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let header = Bundle.main.loadNibNamed("SessionScoreSelectorHeaderView", owner: self, options: nil)?.first as? SessionScoreSelectorHeaderView
        if let header = header {
            header.update(sections[section].index, title: sections[section].title)
            sessionVM.changeShotActiveness(reactingTo: header.tapped)
        }
        return header
    }
}
