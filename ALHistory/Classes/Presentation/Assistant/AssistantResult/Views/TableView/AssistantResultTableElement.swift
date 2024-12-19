//
//  AssistantResultTableElement.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

enum AssistantResultTableElement {
    case questionImageUrl(URL)
    case questionImage(UIImage)
    case questionText(String)
    case loading
    case answer(HistoryAssistantResult.Response)
    case helpful
}
