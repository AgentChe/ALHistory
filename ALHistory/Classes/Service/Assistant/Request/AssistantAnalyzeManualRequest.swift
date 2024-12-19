//
//  AssistantAnalyzeManualRequest.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 09.09.2024.
//

import Alamofire

struct AssistantAnalyzeManualRequest: APIRequestBody {
    let anonymousId: String
    let internalId: String
    let text: String
    
    var url: String {
        GlobalDefinitions.domain + "/api/v1/assistant/history/process"
    }
    
    var method: HTTPMethod {
        .post
    }
    
    var headers: HTTPHeaders? {
        [
            "Access-Token": GlobalDefinitions.apiKey
        ]
    }
    
    var parameters: Parameters? {
        [
            "anonymous_id": anonymousId,
            "internal_id": internalId,
            "text": text
        ]
    }
}
