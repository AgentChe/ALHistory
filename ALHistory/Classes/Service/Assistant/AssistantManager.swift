//
//  AssistantManager.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 09.09.2024.
//

import RxSwift
import RxCocoa

protocol AssistantManagerProtocol {
    func analyze(image: UIImage) -> Single<AssistantAnalyzeImageResult?>
    func analyzeManual(text: String) -> Single<HistoryAssistantResult?>
    func process(threadId: String, isRepeat: Bool) -> Single<HistoryAssistantResult?>
    
    func helpful(threadId: String, helpful: Bool) -> Single<Void>
    
    func recent(page: Int) -> Single<AssistantRecentPage?>
}

final class AssistantManager {
    private lazy var analyzeImage = AssistantAnalyzeImage()
    private lazy var restApiTransport = RestAPITransport()
    private lazy var sessionManager = SessionManager()
}

// MARK: AssistantManagerProtocol
extension AssistantManager: AssistantManagerProtocol {
    func analyze(image: UIImage) -> Single<AssistantAnalyzeImageResult?> {
        Single<AssistantAnalyzeImageResult?>.create { [weak self] single in
            guard let self else { return Disposables.create() }
            
            analyzeImage.upload(image: image) { result in
                single(.success(result))
            }
            
            return Disposables.create()
        }
    }
    
    func analyzeManual(text: String) -> Single<HistoryAssistantResult?> {
        let request = AssistantAnalyzeManualRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            text: text
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { HistoryAssistantResult.map(response: $0) }
    }
    
    func process(threadId: String, isRepeat: Bool) -> Single<HistoryAssistantResult?> {
        let request = AssistantAnalyzeProcessRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            threadId: threadId,
            isRepeat: isRepeat
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { HistoryAssistantResult.map(response: $0) }
    }
    
    func helpful(threadId: String, helpful: Bool) -> Single<Void> {
        let request = AssistantHelpfulRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            threadId: threadId,
            helpful: helpful
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .mapToVoid()
    }
    
    func recent(page: Int) -> Single<AssistantRecentPage?> {
        let request = AssistantRecentRequest(
            anonymousId: sessionManager.anonymousId,
            internalId: sessionManager.internalId,
            page: page
        )
        
        return restApiTransport
            .callServerApi(requestBody: request)
            .map { AssistantRecentPage(response: $0) }
    }
}
