//
//  AssistantResultViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantResultViewModel {
    enum Route {
        case close
    }
    
    enum Action {
        case copy(String)
    }
    
    enum InputData {
        case recognized(AssistantRecognizerController.Result)
        case recentItem(HistoryAssistantResult)
        case manual(String)
    }
    
    struct AssistantResult {
        let inputData: InputData
        let result: HistoryAssistantResult?
        
        init(
            inputData: InputData,
            result: HistoryAssistantResult? = nil
        ) {
            self.inputData = inputData
            self.result = result
        }
    }
    
    private lazy var assistantManager = AssistantManager()
    
    private let inputData: Driver<InputData>
    
    init(recognized: AssistantRecognizerController.Result) {
        inputData = BehaviorRelay(value: InputData.recognized(recognized)).asDriver()
    }
    
    init(recentItem: HistoryAssistantResult) {
        inputData = BehaviorRelay(value: InputData.recentItem(recentItem)).asDriver()
    }
    
    init(manual: String) {
        inputData = BehaviorRelay(value: InputData.manual(manual)).asDriver()
    }
}

// MARK: Public
extension AssistantResultViewModel {
    struct Input {
        let didTapClose: Signal<Void>
        let didTapRefresh: Signal<AssistantResult>
        let didTapCopy: Signal<HistoryAssistantResult.Response>
        let didTapLike: Signal<AssistantResult>
        let didTapDislike: Signal<AssistantResult>
    }
    
    struct Output {
        let route: Driver<Route>
        let action: Driver<Action>
        let elements: Driver<[AssistantResultTableElement]>
        let currentResult: Driver<AssistantResult>
    }
    
    func configure(input: Input) -> Output {
        let currentResult = makeResult(
            inputData: inputData,
            didTapRefresh: input.didTapRefresh,
            didTapLike: input.didTapLike,
            didTapDislike: input.didTapDislike
        )
        
        return Output(
            route: makeRoute(didTapClose: input.didTapClose),
            action: makeAction(didTapCopy: input.didTapCopy),
            elements: makeElements(
                inputData: inputData,
                didTapRefresh: input.didTapRefresh,
                assistantResult: currentResult
            ),
            currentResult: currentResult
        )
    }
}

// MARK: Private
private extension AssistantResultViewModel {
    func makeRoute(didTapClose: Signal<Void>) -> Driver<Route> {
        let close = didTapClose
            .map { Route.close }
            .asDriver(onErrorDriveWith: .never())
        
        return Driver
            .merge(close)
    }
    
    func makeElements(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<AssistantResult>,
        assistantResult: Driver<AssistantResult>
    ) -> Driver<[AssistantResultTableElement]> {
        let initalElements = makeInitialElements(inputData: inputData)
        let refreshElements = makeRefreshElements(didTapRefresh: didTapRefresh)
        let resultElements = makeResultElements(assistantResult: assistantResult)
        return Driver.merge(initalElements, refreshElements, resultElements)
    }
    
    func makeInitialElements(inputData: Driver<InputData>) -> Driver<[AssistantResultTableElement]> {
        inputData
            .compactMap { inputData -> [AssistantResultTableElement]? in
                switch inputData {
                case .recognized(let recognized):
                    return [.questionImageUrl(recognized.recognized.analyzeImageResult.url), .loading]
                case .manual(let text):
                    return [.questionText(text), .loading]
                case .recentItem:
                    return nil
                }
            }
    }
    
    func makeRefreshElements(didTapRefresh: Signal<AssistantResult>) -> Driver<[AssistantResultTableElement]> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .map { assistantResult -> [AssistantResultTableElement] in
                guard let result = assistantResult.result else { return [] }
                
                return [
                    {
                        if let imageUrl = result.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(result.request.content)
                        }
                    }(),
                    .loading
                ]
            }
    }
    
    func makeResultElements(assistantResult: Driver<AssistantResult>) -> Driver<[AssistantResultTableElement]> {
        assistantResult
            .map { assistantResult -> [AssistantResultTableElement] in
                guard let result = assistantResult.result else { return [] }
                
                return [
                    {
                        if let imageUrl = result.request.imageUrl {
                            return .questionImageUrl(imageUrl)
                        } else {
                            return .questionText(result.request.content)
                        }
                    }(),
                    .answer(result.response),
                    (result.helpful == nil) ? .helpful : nil
                ].compactMap { $0 }
            }
    }
    
    func makeResult(
        inputData: Driver<InputData>,
        didTapRefresh: Signal<AssistantResult>,
        didTapLike: Signal<AssistantResult>,
        didTapDislike: Signal<AssistantResult>
    ) -> Driver<AssistantResult> {
        let initialResult = makeInitialResult(inputData: inputData)
        let refreshResult = makeRefreshResult(didTapRefresh: didTapRefresh)
        let helpfulResult = makeHelpfulResult(
            didTapLike: didTapLike,
            didTapDislike: didTapDislike
        )
        return Driver.merge(initialResult, refreshResult, helpfulResult)
    }
    
    func makeRefreshResult(didTapRefresh: Signal<AssistantResult>) -> Driver<AssistantResult> {
        didTapRefresh
            .asDriver(onErrorDriveWith: .never())
            .flatMapLatest { [weak self] currentResult -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                return obtainResult(currentResult, refresh: true)
            }
    }
    
    func makeHelpfulResult(
        didTapLike: Signal<AssistantResult>,
        didTapDislike: Signal<AssistantResult>
    ) -> Driver<AssistantResult> {
        let helpful = Signal
            .merge(
                didTapLike.map { (true, $0) },
                didTapDislike.map { (false, $0) }
            )
            .asDriver(onErrorDriveWith: .never())
        
        return helpful
            .flatMapFirst { [weak self] args -> Driver<AssistantResult> in
                guard let self else { return .never() }
                
                let (helpful, currentAssistantResult) = args
                
                guard let currentResult = currentAssistantResult.result else {
                    return .just(currentAssistantResult)
                }
                
                return assistantManager
                    .helpful(threadId: currentResult.threadId, helpful: helpful)
                    .catchAndReturn(())
                    .asDriver(onErrorDriveWith: .never())
                    .flatMap { [weak self] void -> Driver<AssistantResult> in
                        guard let self else { return .never() }
                        
                        return obtainResult(currentAssistantResult, refresh: false)
                    }
            }
    }
    
    func obtainResult(_ result: AssistantResult, refresh: Bool) -> Driver<AssistantResult> {
        guard let currentResult = result.result else {
            return .just(result)
        }
        
        return assistantManager
            .process(threadId: currentResult.threadId, isRepeat: refresh)
            .asDriver(onErrorJustReturn: nil)
            .map { response -> AssistantResult in
                guard let response else { return result }
                
                return AssistantResult(inputData: result.inputData, result: response)
            }
    }
    
    func makeInitialResult(inputData: Driver<InputData>) -> Driver<AssistantResult> {
        inputData.flatMapLatest { [weak self] inputData -> Driver<AssistantResult> in
            guard let self else { return .never() }
            
            switch inputData {
            case .recognized(let recognized):
                return assistantManager
                    .process(threadId: recognized.recognized.analyzeImageResult.threadId, isRepeat: false)
                    .asDriver(onErrorJustReturn: nil)
                    .map { response -> AssistantResult in
                        guard let response else { return AssistantResult(inputData: inputData) }
                        
                        return AssistantResult(inputData: inputData, result: response)
                    }
            case .manual(let text):
                return assistantManager
                    .analyzeManual(text: text)
                    .asDriver(onErrorJustReturn: nil)
                    .map { response -> AssistantResult in
                        guard let response else { return AssistantResult(inputData: inputData) }
                        
                        return AssistantResult(inputData: inputData, result: response)
                    }
            case .recentItem(let item):
                let result = AssistantResult(inputData: inputData, result: item)
                return .just(result)
            }
        }
    }
    
    func makeAction(didTapCopy: Signal<HistoryAssistantResult.Response>) -> Driver<Action> {
        didTapCopy
            .asDriver(onErrorDriveWith: .never())
            .filter { $0.detected }
            .map { $0.data?.body ?? "" }
            .map { Action.copy($0) }
    }
}
