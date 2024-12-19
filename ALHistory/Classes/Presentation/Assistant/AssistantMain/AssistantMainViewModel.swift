//
//  AssistantMainViewModel.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 24.09.2024.
//

import RxSwift
import RxCocoa

final class AssistantMainViewModel {
    enum Route {
        case recent
        case recentItem(HistoryAssistantResult)
        case recognizeImage
        case manual(String)
    }
    
    private lazy var assistantManager = AssistantManager()
}

// MARK: Public
extension AssistantMainViewModel {
    struct Input {
        let didTapRecent: Signal<Void>
        let didSelectRecentItem: Signal<HistoryAssistantResult>
        let didTapCamera: Signal<Void>
        let didTapDone: Signal<String>
    }
    
    struct Output {
        let elements: Driver<[AssistantMainTableElement]>
        let route: Driver<Route>
    }
    
    func configure(input: Input) -> Output {
        Output(
            elements: makeElements(history: makeHistoryElements()),
            route: makeRoute(
                didTapRecent: input.didTapRecent,
                didSelectRecentItem: input.didSelectRecentItem,
                didTapCamera: input.didTapCamera,
                didTapDone: input.didTapDone
            )
        )
    }
}

// MARK: Private
private extension AssistantMainViewModel {
    func makeElements(history: Driver<[AssistantMainTableElement]>) -> Driver<[AssistantMainTableElement]> {
        history
            .map { history -> [AssistantMainTableElement] in
                var result: [AssistantMainTableElement] = [.input]
                
                if !history.isEmpty {
                    result.append(.recentTitle)
                    result.append(contentsOf: history)
                }
                
                return result
            }
            .startWith([.input])
    }
    
    func makeHistoryElements() -> Driver<[AssistantMainTableElement]> {
        assistantManager
            .recent(page: 1)
            .map { $0?.history ?? [] }
            .asDriver(onErrorJustReturn: [])
            .map { $0.map { HistoryTableElement(item: $0) } }
            .map { Array($0.prefix(3)) }
            .map { $0.map { AssistantMainTableElement.recentItem($0) } }
    }
    
    func makeRoute(
        didTapRecent: Signal<Void>,
        didSelectRecentItem: Signal<HistoryAssistantResult>,
        didTapCamera: Signal<Void>,
        didTapDone: Signal<String>
    ) -> Driver<Route> {
        let recent = didTapRecent
            .map { Route.recent }
            .asDriver(onErrorDriveWith: .never())
        
        let recentItem = didSelectRecentItem
            .map { Route.recentItem($0) }
            .asDriver(onErrorDriveWith: .never())
        
        let recognizeImage = didTapCamera
            .asDriver(onErrorDriveWith: .never())
            .map { Route.recognizeImage }
        
        let manual = didTapDone
            .asDriver(onErrorDriveWith: .never())
            .map { Route.manual($0) }
        
        return Driver
            .merge(recent, recentItem, recognizeImage, manual)
    }
}
