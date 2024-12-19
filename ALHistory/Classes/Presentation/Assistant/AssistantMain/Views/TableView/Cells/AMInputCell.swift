//
//  AMInputCell.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import UIKit

final class AMInputCell: UITableViewCell {
    var didTapCamera: (() -> Void)?
    var didTapDone: ((String) -> Void)?
    
    lazy var container = makeContainer()
    lazy var textView = makeTextView()
    lazy var cameraButton = makeCameraButton()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        makeConstraints()
        initialize()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: Private
private extension AMInputCell {
    func initialize() {
        backgroundColor = UIColor.clear
        contentView.backgroundColor = UIColor.clear
        selectionStyle = .none
        
        textView.didTapDone = { [weak self] text in
            self?.didTapDone?(text)
        }
    }
    
    @objc
    func cameraTapped() {
        didTapCamera?()
    }
}

// MARK: Make constraints
private extension AMInputCell {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            container.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16.scale),
            container.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16.scale),
            container.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16.scale),
            container.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            container.heightAnchor.constraint(equalToConstant: 378.scale)
        ])
        
        NSLayoutConstraint.activate([
            textView.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            textView.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            textView.bottomAnchor.constraint(equalTo: cameraButton.topAnchor, constant: -8.scale),
            textView.topAnchor.constraint(equalTo: container.topAnchor, constant: 16.scale)
        ])
        
        NSLayoutConstraint.activate([
            cameraButton.widthAnchor.constraint(equalToConstant: 24.scale),
            cameraButton.heightAnchor.constraint(equalToConstant: 24.scale),
            cameraButton.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -24.scale),
            cameraButton.bottomAnchor.constraint(equalTo: container.bottomAnchor, constant: -24.scale)
        ])
    }
}

// MARK: Lazy initialization
private extension AMInputCell {
    func makeContainer() -> UIView {
        let view = UIView()
        view.backgroundColor = Appearance.mono100
        view.layer.cornerRadius = 16.scale
        view.layer.borderColor = Appearance.main200.cgColor
        view.layer.borderWidth = 1.scale
        view.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(view)
        return view
    }
    
    func makeTextView() -> AMTextView {
        let view = AMTextView()
        view.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(view)
        return view
    }
    
    func makeCameraButton() -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: "AssistantMain.Camera"), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        view.addTarget(self, action: #selector(cameraTapped), for: .touchUpInside)
        container.addSubview(view)
        return view
    }
}
