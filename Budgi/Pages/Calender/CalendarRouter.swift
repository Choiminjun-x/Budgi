//
//  CalendarRouter.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs

protocol CalendarInteractable: Interactable {
    var router: CalendarRouting? { get set }
    var listener: CalendarListener? { get set }
}

protocol CalendarViewControllable: ViewControllable {
    // TODO: Declare methods the router invokes to manipulate the view hierarchy.
}

final class CalendarRouter: ViewableRouter<CalendarInteractable, CalendarViewControllable>, CalendarRouting {

    override init(interactor: CalendarInteractable,
                  viewController: CalendarViewControllable) {
        super.init(interactor: interactor, viewController: viewController)
        interactor.router = self
    }
    
}
