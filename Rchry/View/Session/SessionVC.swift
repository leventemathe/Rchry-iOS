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
    
    var sessionVM: SessionVM!
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScoresTableView()
    }
    
    private func setupScoresTableView() {
        let rowHeight = scoreSelectorTableView.rowHeight
        
        let sessionDatasource = SessionScoreSelectorDatasource(sessionVM: sessionVM, rowHeight: rowHeight)
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
        case .next(let newElements):
            handleNewElements(newElements, tableView)
        default:
            break
        }
    }
    
    func handleNewElements(_ newElements: Element, _ tableView: UITableView) {        
        // new section
        let newSections = getNewSections(newElements)
        // rows thats activeness changed
        let changedRows = getChangedRows(newElements)
        
        self.elements = newElements
        
        if newSections.count > 0 {
            tableView.beginUpdates()
            tableView.insertSections(newSections, with: .left)
            tableView.endUpdates()
            let indexPath = IndexPath(row: elements.last!.scores.count-1, section: elements.count-1)
            tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
        
        if changedRows.count > 0 {
            tableView.beginUpdates()
            tableView.reloadRows(at: changedRows, with: .right)
            tableView.endUpdates()
        }
    }
    
    func getNewSections(_ newElements: Element) -> IndexSet {
        var newSections = IndexSet()
        if newElements.count > elements.count {
            for i in elements.count..<newElements.count {
                newSections.insert(i)
            }
        }
        return newSections
    }
    
    func getChangedRows(_ newElements: Element) -> [IndexPath] {
        var changedRows = [IndexPath]()
        for i in 0..<elements.count {
            if elements[i].active != newElements[i].active {
                for j in 0..<elements[i].scores.count {
                    changedRows.append(IndexPath(row: j, section: i))
                }
            }
        }
        
        return changedRows
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return elements.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return elements[section].scores.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SessionScoreSelectorCell") as! SessionScoreSelectorCell
        
        let owner = elements[indexPath.section].scores[indexPath.row].0
        let selectedScore = elements[indexPath.section].scores[indexPath.row].1
        let sessionScoreSelctorVM = SessionScoreSelectorVM(index: indexPath.section, owner: owner, scores: sessionVM.possibleScores, score: selectedScore)
        
        cell.update(sessionScoreSelectorVM: sessionScoreSelctorVM)
        
        let scoreByUserAndIndex = sessionScoreSelctorVM.scoreByUserAndIndex
        sessionVM.setScoreByUserAndIndex(reactingTo: scoreByUserAndIndex, disposedBy: cell.disposeBag)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return elements[indexPath.section].active ? rowHeight : 0.0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 56
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        // TODO: cache these and get them from array?
        let header = Bundle.main.loadNibNamed("SessionScoreSelectorHeaderView", owner: self, options: nil)?.first as? SessionScoreSelectorHeaderView
        if let header = header {
            header.update(elements[section].index, title: elements[section].title)
            sessionVM.setShotActiveness(reactingTo: header.tapped, disposedBy: header.disposeBag)
        }
        return header
    }
}
