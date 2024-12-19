//
//  AssistantCameraView.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit

final class AssistantCameraView: UIView {
    lazy var closeButton = makeTapAreaButton(imageName: "AssistantCamera.Close")
    lazy var wallpapersButton = makeTapAreaButton(imageName: "AssistantCamera.Wallpapers")
    lazy var takeButton = makeTapAreaButton(imageName: "AssistantCamera.Take")
    lazy var flashButton = makeTapAreaButton(imageName: "AssistantCamera.Flash")
    lazy var permissionProblemView = makePermissionProblemView()
    
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
private extension AssistantCameraView {
    func initialize() {
        backgroundColor = Appearance.mono200
    }
}

// MARK: Make constraints
private extension AssistantCameraView {
    func makeConstraints() {
        NSLayoutConstraint.activate([
            closeButton.widthAnchor.constraint(equalToConstant: 40.scale),
            closeButton.heightAnchor.constraint(equalToConstant: 40.scale),
            closeButton.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 16.scale),
            closeButton.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 5.scale)
        ])
        
        NSLayoutConstraint.activate([
            wallpapersButton.widthAnchor.constraint(equalToConstant: 40.scale),
            wallpapersButton.heightAnchor.constraint(equalToConstant: 40.scale),
            wallpapersButton.trailingAnchor.constraint(equalTo: takeButton.leadingAnchor, constant: -32.scale),
            wallpapersButton.centerYAnchor.constraint(equalTo: takeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            takeButton.widthAnchor.constraint(equalToConstant: 72.scale),
            takeButton.heightAnchor.constraint(equalToConstant: 72.scale),
            takeButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            takeButton.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -26.scale)
        ])
        
        NSLayoutConstraint.activate([
            flashButton.widthAnchor.constraint(equalToConstant: 40.scale),
            flashButton.heightAnchor.constraint(equalToConstant: 40.scale),
            flashButton.leadingAnchor.constraint(equalTo: takeButton.trailingAnchor, constant: 32.scale),
            flashButton.centerYAnchor.constraint(equalTo: takeButton.centerYAnchor)
        ])
        
        NSLayoutConstraint.activate([
            permissionProblemView.leadingAnchor.constraint(equalTo: leadingAnchor),
            permissionProblemView.trailingAnchor.constraint(equalTo: trailingAnchor),
            permissionProblemView.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }
}

// MARK: Lazy initialization
private extension AssistantCameraView {
    func makeTapAreaButton(imageName: String) -> TapAreaButton {
        let view = TapAreaButton()
        view.setImage(UIImage(named: imageName), for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
    
    func makePermissionProblemView() -> AssistantCameraPermissionProblemView {
        let view = AssistantCameraPermissionProblemView()
        view.isHidden = true
        view.translatesAutoresizingMaskIntoConstraints = false
        addSubview(view)
        return view
    }
}
