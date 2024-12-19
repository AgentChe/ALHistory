//
//  AssistantCameraViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantCameraViewModel {
    enum Route {
        case dismiss, selectImageFromLibrary, requestPermissionInSettings
    }
    
    enum Action {
        case takePhoto
    }
}

// MARK: Public
extension AssistantCameraViewModel {
    struct Input {
        let didTapDismiss: Signal<Void>
        let didTapSelectImageFromLibrary: Signal<Void>
        let didTapTakePhoto: Signal<Void>
        let didTapAllowAccess: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(
                didTapDismiss: input.didTapDismiss,
                didTapSelectImageFromLibrary: input.didTapSelectImageFromLibrary,
                didTapAllowAccess: input.didTapAllowAccess
            ),
            action: makeAction(didTapTakePhoto: input.didTapTakePhoto)
        )
    }
}

// MARK: Private
private extension AssistantCameraViewModel {
    func makeRoute(
        didTapDismiss: Signal<Void>,
        didTapSelectImageFromLibrary: Signal<Void>,
        didTapAllowAccess: Signal<Void>
    ) -> Driver<Route> {
        let dismiss = didTapDismiss
            .map { Route.dismiss }
            .asDriver(onErrorDriveWith: .never())
        
        let selectImageFromLibrary = didTapSelectImageFromLibrary
            .map { Route.selectImageFromLibrary }
            .asDriver(onErrorDriveWith: .never())
        
        let requestPermissionInSettings = didTapAllowAccess
            .map { Route.requestPermissionInSettings }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(dismiss, selectImageFromLibrary, requestPermissionInSettings)
    }
    
    func makeAction(didTapTakePhoto: Signal<Void>) -> Driver<Action> {
        let takePhoto = didTapTakePhoto
            .map { Action.takePhoto }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(takePhoto)
    }
}
