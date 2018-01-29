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
    
    var sessionVM: SessionVM!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoreSelectorCellHeight()
        setupScoresTableView()
    }
    
    private func setupScoreSelectorCellHeight() {
        scoreSelectorCellHeight = scoreSelectorTableView.rowHeight
    }
    
    private func setupScoresTableView() {
        let sessionDatasource = SessionScoreSelectorDatasource(sessionVM: sessionVM, rowHeight: scoreSelectorCellHeight)
        sessionVM.shotsDatasource.bind(to: scoreSelectorTableView.rx.items(dataSource: sessionDatasource)).disposed(by: disposeBag)
        scoreSelectorTableView.rx.setDelegate(sessionDatasource).disposed(by: disposeBag)
    }
}

class SessionScoreSelectorDatasource: NSObject, RxTableViewDataSourceType, UITableViewDataSource, UITableViewDelegate {
    
    typealias Element = [Shot]
    
    private weak var sessionVM: SessionVM!
    private let disposeBag = DisposeBag()
    
    private var rowHeight: CGFloat
    
    private var elements = Element()
    
    init(sessionVM: SessionVM,
         rowHeight: CGFloat) {
        self.sessionVM = sessionVM
        self.rowHeight = rowHeight
    }
    
    func tableView(_ tableView: UITableView, observedEvent: Event<Element>) {
        switch observedEvent {
        case .next(let elements):
            self.elements = elements
            tableView.reloadData()
        default:
            break
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[section].active ? elements[section].scores.count : 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionScoreSelectorCell") as! SessionScoreSelectorCell
        let owner = elements[indexPath.section].scores[indexPath.row].0
        cell.update(owner: owner, scoresDatasource: sessionVM.possibleScores)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return rowHeight
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // TODO: cache these and get them from array
        let header = Bundle.main.loadNibNamed("SessionScoreSelectorHeaderView", owner: self, options: nil)?.first as? SessionScoreSelectorHeaderView
        if let header = header {
            header.update(elements[section].index, title: elements[section].title)
            let tap = header.tapped
            sessionVM.setShotActiveness(reactingTo: tap)
        }
        return header
    }
}
