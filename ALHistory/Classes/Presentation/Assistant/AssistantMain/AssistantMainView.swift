//
//  AssistantMainView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AssistantMainView: UIView {
    lazy var tableView = makeTableView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AssistantMainView {
    func initialize() {
        backgroundColor = Appearance.main100
    }
}

// MARK: Make constraints
private extension AssistantMainView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor),
            tableView.bottomAnchor.constraint(equalTo: keyboardLayoutGuide.topAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantMainView {
    func makeTableView() -> AssistantMainTableView {
        let view = AssistantMainTableView()
        view.backgroundColor = UIColor.clear
        view.separatorStyle = .none
        view.showsVerticalScrollIndicator = false
        view.contentInset = UIEdgeInsets(vertical: 16.scale)
        view.setContentOffset(CGPoint(x: 0, y: -16.scale), animated: false)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
