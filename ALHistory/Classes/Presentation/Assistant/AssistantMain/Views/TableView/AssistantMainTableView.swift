//
//  AssistantMainTableView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit
import RxSwift
import RxCocoa

final class AssistantMainTableView: UITableView {
    private lazy var elements = [AssistantMainTableElement]()
    
    private lazy var inputCell = AMInputCell(style: .default, reuseIdentifier: nil)
    
    private lazy var didTapRecentTrigger = PublishRelay<Void>()
    private lazy var didSelectRecentItemTrigger = PublishRelay<HistoryAssistantResult>()
    private lazy var didTapCameraTrigger = PublishRelay<Void>()
    private lazy var didTapDoneTrigger = PublishRelay<String>()
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Public
extension AssistantMainTableView {
    func setup(elements: [AssistantMainTableElement]) {
        self.elements = elements
        
        reloadData()
    }
    
    var didTapRecent: Signal<Void> {
        didTapRecentTrigger.asSignal()
    }
    
    var didSelectRecentItem: Signal<HistoryAssistantResult> {
        didSelectRecentItemTrigger.asSignal()
    }
    
    var didTapCamera: Signal<Void> {
        didTapCameraTrigger.asSignal()
    }
    
    var didTapDone: Signal<String> {
        didTapDoneTrigger.asSignal()
    }
}

// MARK: UITableViewDataSource
extension AssistantMainTableView: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        elements.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch elements[indexPath.row] {
        case .input:
            return inputCell
        case .recentTitle:
            return dequeueReusableCell(withIdentifier: String(describing: AMHistoryTitleCell.self), for: indexPath)
        case .recentItem(let historyItem):
            switch historyItem.mode {
            case .image(let url):
                let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryImageCell.self), for: indexPath) as! HistoryImageCell
                cell.setup(imageUrl: url, created: historyItem.created)
                return cell
            case .text(let content):
                let cell = dequeueReusableCell(withIdentifier: String(describing: HistoryTextCell.self), for: indexPath) as! HistoryTextCell
                cell.setup(content: content, created: historyItem.created)
                return cell
            }
        }
    }
}

// MARK: UITableViewDelegate
extension AssistantMainTableView: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch elements[indexPath.row] {
        case .recentTitle:
            didTapRecentTrigger.accept(Void())
        case .recentItem(let element):
            didSelectRecentItemTrigger.accept(element.item)
        default:
            return
        }
    }
}

// MARK: Private
private extension AssistantMainTableView {
    func initialize() {
        register(AMHistoryTitleCell.self, forCellReuseIdentifier: String(describing: AMHistoryTitleCell.self))
        register(HistoryImageCell.self, forCellReuseIdentifier: String(describing: HistoryImageCell.self))
        register(HistoryTextCell.self, forCellReuseIdentifier: String(describing: HistoryTextCell.self))
        
        dataSource = self
        delegate = self
        
        inputCell.didTapCamera = { [weak self] in
            self?.didTapCameraTrigger.accept(Void())
        }
        
        inputCell.didTapDone = { [weak self] text in
            self?.didTapDoneTrigger.accept(text)
        }
    }
}
