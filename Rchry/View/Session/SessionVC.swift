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
    var scoreSelectorCellHeight: CGFloat!
    
    var sessionVM = SessionVM()
    
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoreSelectorCellHeight()
        setupScoresTableView()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    private func setupScoreSelectorCellHeight() {
        scoreSelectorCellHeight = scoreSelectorTableView.rowHeight
    }
    
    private func setupScoresTableView() {
        let sessionDatasource = SessionScoreSelectorDatasource(sessionVM: sessionVM, rowHeight: scoreSelectorCellHeight)
        sessionVM.scoresDatasource.bind(to: scoreSelectorTableView.rx.items(dataSource: sessionDatasource)).disposed(by: disposeBag)
        scoreSelectorTableView.rx.setDelegate(sessionDatasource).disposed(by: disposeBag)
    }
}

class SessionScoreSelectorDatasource: NSObject, RxTableViewDataSourceType, UITableViewDataSource, UITableViewDelegate {
    
    typealias Element = [SessionSection]

    private var sections = Element()
    private var rowHeight: CGFloat
    
    private weak var sessionVM: SessionVM!
    
    private let disposeBag = DisposeBag()
    
    init(sessionVM: SessionVM,
         rowHeight: CGFloat) {
        self.sessionVM = sessionVM
        self.rowHeight = rowHeight
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let sessionSections):
            sections = sessionSections
            tableView.reloadData()
            /*
            tableView.beginUpdates()
            tableView.reloadSections(IndexSet(sessionSections.map { $0.index }), with: .automatic)
            tableView.endUpdates()
             */
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // return sections[section].active ? (sections[section].scoresByUser?.count ?? 0) : 0
        return sections[section].scoresByUser?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionScoreSelectorCell") as! SessionScoreSelectorCell
        // TODO: inject scores from vm
        let scores = Observable<[Float]>.just([0,5,8,10,11])
        if let owner = sections[indexPath.section].scoresByUser?[indexPath.row].0 {
            cell.update(owner: owner, scoresDatasource: scores)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        return section.active ? rowHeight : 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // TODO: cache these and get them from array
        let header = Bundle.main.loadNibNamed("SessionScoreSelectorHeaderView", owner: self, options: nil)?.first as? SessionScoreSelectorHeaderView
        if let header = header {
            header.update(sections[section].index, title: sections[section].title)
            sessionVM.changeShotActiveness(reactingTo: header.tapped)
        }
        return header
    }
}
