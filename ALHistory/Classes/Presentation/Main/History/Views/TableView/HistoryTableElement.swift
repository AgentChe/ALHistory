//
//  HistoryTableElement.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 12.09.2024.
//

import Foundation

struct HistoryTableElement {
    enum Mode {
        case image(URL)
        case text(String)
    }
    
    let mode: Mode
    let created: String
    let item: HistoryAssistantResult
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale.current
        formatter.dateFormat = "MMMM dd, yyyy"
        return formatter
    }()
    
    init(item: HistoryAssistantResult) {
        self.mode = {
            if let url = item.request.imageUrl {
                return .image(url)
            }
            return .text(item.request.content)
        }()
        self.created = {
            let date = Date(timeIntervalSince1970: item.created)
            return HistoryTableElement.dateFormatter.string(from: date)
        }()
        self.item = item
    }
}
