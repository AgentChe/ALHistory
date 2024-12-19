//
//  AssistantRecentPage.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

struct AssistantRecentPage {
    let history: [HistoryAssistantResult]
    let page: Page
    
    init?(response: Any) {
        guard
            let json = response as? [String: Any],
            let body = json["body"] as? [String: Any]
        else { return nil }
        
        let history: [HistoryAssistantResult] = {
            guard let array = body["history"] as? [[String: Any]] else { return [] }
            return array.compactMap { item -> HistoryAssistantResult? in
                HistoryAssistantResult(body: item)
            }
        }()
        
        let page: Page? = {
            guard let pagination = body["pagination"] as? [String: Any] else { return nil }
            return Page(json: pagination)
        }()
        guard let page else { return nil }
        
        self.history = history
        self.page = page
    }
}
