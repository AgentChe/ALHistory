//
//  AssistantImageResizeViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 13.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantImageResizeViewModel {
    enum Route {
        case cancel
    }
    
    enum Action {
        case crop
        case error
        case result(AssistantImageResizeViewController.Result)
    }
    
    private let fromCamera: Driver<UIImage>
    
    private lazy var assistantManager = AssistantManager()
    
    init(fromCamera: UIImage) {
        self.fromCamera = BehaviorRelay(value: fromCamera).asDriver()
    }
}

// MARK: Public
extension AssistantImageResizeViewModel {
    struct Input {
        let didTapCancel: Signal<Void>
        let didTapDone: Signal<Void>
        let didCroppedImage: Signal<UIImage>
        let tryAgain: Signal<Void>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let originalImage: Driver<UIImage>
    }
    
    func configure(input: Input) -> Output {
        Output(
            route: makeRoute(didTapCancel: input.didTapCancel),
            action: makeAction(
                didTapDone: input.didTapDone,
                croppedImage: input.didCroppedImage,
                tryAgain: input.tryAgain
            ),
            originalImage: makeOriginalImage()
        )
    }
}

// MARK: Private
private extension AssistantImageResizeViewModel {
    func makeRoute(didTapCancel: Signal<Void>) -> Driver<Route> {
        didTapCancel
            .map { Route.cancel }
            .asDriver(onErrorDriveWith: .never())
    }
    
    func makeAction(
        didTapDone: Signal<Void>,
        croppedImage: Signal<UIImage>,
        tryAgain: Signal<Void>
    ) -> Driver<Action> {
        let crop = didTapDone
            .map { Action.crop }
            .asDriver(onErrorDriveWith: .never())
        
        let errorOrResult = Signal
            .merge(
                croppedImage,
                tryAgain.withLatestFrom(croppedImage)
            )
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] croppedImage -> Driver<Action> in
                guard let self else { return .never() }
                    
                return assistantManager
                    .analyze(image: croppedImage)
                    .asDriver(onErrorJustReturn: nil)
                    .map { result -> Action in
                        guard let result else { return .error }
                        return .result(.init(croppedImage: croppedImage, analyzeImageResult: result))
                    }
            }
        
        return Driver
            .merge(crop, errorOrResult)
    }
    
    func makeOriginalImage() -> Driver<UIImage> {
        fromCamera
            .asDriver(onErrorDriveWith: .never())
    }
}
