//
//  HomeRouter.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/22/26.
//

import Foundation
import RIBs

protocol HomeInteractable: Interactable {
    var router: HomeRouting? { get set }
    var listener: HomeListener? { get set }
}

protocol HomeViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class HomeRouter: ViewableRouter<HomeInteractable, HomeViewControllable>, HomeRouting {
    
    override init(interactor: HomeInteractable,
                  viewController: HomeViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
}
