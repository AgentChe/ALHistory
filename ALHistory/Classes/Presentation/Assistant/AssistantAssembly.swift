//
//  AssistantAssembly.swift
//  ScienceSolver
//
//  Created by Андрей Чернышев on 18.09.2024.
//

import UIKit

final class AssistantAssembly {
    func recognize(from: UIViewController) {
        let nc = NavigationController()
        nc.modalPresentationStyle = .fullScreen
        
        let recognizerVC = AssistantRecognizerController.make(close: { [weak nc] in
            nc?.dismiss(animated: true)
        }, result: { [weak nc] result in
            let resultVC = AssistantResultViewController.make(recognized: result) { [weak nc] in
                nc?.dismiss(animated: true)
            }
            nc?.pushViewController(resultVC, animated: true)
        })
        
        nc.setViewControllers([recognizerVC], animated: false)
        
        from.present(nc, animated: true)
    }
    
    func manualAnalyze(data: String, from: UINavigationController) {
        let resultVC = AssistantResultViewController.make(manual: data) { [weak from] in
            from?.popViewController(animated: true)
        }
        from.pushViewController(resultVC, animated: true)
    }
    
    func recent(item: HistoryAssistantResult, from: UINavigationController) {
        let resultVC = AssistantResultViewController.make(recentItem: item) { [weak from] in
            from?.popViewController(animated: true)
        }
        from.pushViewController(resultVC, animated: true)
    }
}
