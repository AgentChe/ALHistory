//
//  AssistantCameraViewController.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import UIKit
import RxSwift
import PhotosUI
import AVFoundation

final class AssistantCameraViewController: UIViewController {
    var didClose: (() -> Void)?
    var didResult: ((UIImage) -> Void)?
    
    private lazy var mainView = AssistantCameraView()
    
    private lazy var viewModel = AssistantCameraViewModel()
    
    private lazy var disposeBag = DisposeBag()
    
    private lazy var cameraService: CameraService = {
        let cameraService = CameraService()
        cameraService.delegate = self
        return cameraService
    }()
    
    override func loadView() {
        view = mainView
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let output = viewModel.configure(input: AssistantCameraViewModel.Input(
            didTapDismiss: mainView.closeButton.rx.tap.asSignal(),
            didTapSelectImageFromLibrary: mainView.wallpapersButton.rx.tap.asSignal(),
            didTapTakePhoto: mainView.takeButton.rx.tap.asSignal(),
            didTapAllowAccess: mainView.permissionProblemView.allowAccessButton.rx.tap.asSignal()
        ))
        
        output.route
            .drive(Binder(self) { base, route in
                base.route(route)
            })
            .disposed(by: disposeBag)
        
        output.action
            .drive(Binder(self) { base, action in
                base.action(action)
            })
            .disposed(by: disposeBag)
        
        rx.methodInvoked(#selector(UIViewController.viewDidLayoutSubviews))
            .take(1)
            .bind(to: Binder(self) { base, _ in
                base.setupCameraLayer()
            })
            .disposed(by: disposeBag)
    }
}

// MARK: AssistantCameraViewController
extension AssistantCameraViewController {
    static func make() -> AssistantCameraViewController {
        let vc = AssistantCameraViewController()
        vc.modalPresentationStyle = .fullScreen
        return vc
    }
}

// MARK: PHPickerViewControllerDelegate
extension AssistantCameraViewController: PHPickerViewControllerDelegate {
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        
        let itemProvider = results
            .map (\.itemProvider)
            .filter { $0.canLoadObject(ofClass: UIImage.self) }
            .first
        guard let itemProvider else { return }
        
        itemProvider.loadObject(ofClass: UIImage.self) { image, error in
            if let image = image as? UIImage {
                DispatchQueue.main.async { [weak self] in
                    self?.complete(image: image)
                }
            }
        }
    }
}

// MARK: CameraServiceDelegate
extension AssistantCameraViewController: CameraServiceDelegate {
    func setPhoto(image: UIImage) {
        complete(image: image)
    }
}

// MARK: Private
private extension AssistantCameraViewController {
    func route(_ route: AssistantCameraViewModel.Route) {
        switch route {
        case .dismiss:
            didClose?()
        case .selectImageFromLibrary:
            var configuration = PHPickerConfiguration()
            configuration.filter = .images
            configuration.selectionLimit = 1
            configuration.preferredAssetRepresentationMode = .automatic
            
            let picker = PHPickerViewController(configuration: configuration)
            picker.delegate = self
            
            present(picker, animated: true)
        case .requestPermissionInSettings:
            guard let url = URL(string: UIApplication.openSettingsURLString) else { return }
            
            UIApplication.shared.open(url)
        }
    }
    
    func action(_ action: AssistantCameraViewModel.Action) {
        switch action {
        case .takePhoto:
            let photoSettings = AVCapturePhotoSettings()
            photoSettings.isHighResolutionPhotoEnabled = true
            photoSettings.flashMode = .off
            cameraService.photoOutput.capturePhoto(with: photoSettings, delegate: cameraService)
        }
    }
    
    func complete(image: UIImage?) {
        guard let image else { return }
        
        didResult?(image)
    }
    
    func setupCameraLayer() {
        func ui(authorized: Bool) {
            mainView.permissionProblemView.isHidden = authorized
            mainView.takeButton.isHidden = !authorized
            
            if authorized {
                let previewLayer = AVCaptureVideoPreviewLayer(session: cameraService.captureSession) as AVCaptureVideoPreviewLayer
                previewLayer.frame = mainView.bounds
                previewLayer.videoGravity = .resizeAspectFill
                mainView.layer.insertSublayer(previewLayer, at: 0)
            }
        }
        
        let cameraAuthStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthStatus {
        case .authorized:
            ui(authorized: true)
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { authorized in
                ui(authorized: authorized)
            }
        default:
            ui(authorized: false)
        }
    }
}
