//
//  CalendarBuilder.swift
//  iOS-StudyHub
//
//  Created by 최민준(Minjun Choi) on 1/21/26.
//

import Foundation
import RIBs

protocol CalendarDependency: Dependency {
    var dateGenerator: DateGenerator { get }
}

final class CalendarComponent: Component<CalendarDependency>, TransactionInputDependency, TransactionDetailDependency {
    var dateGenerator: DateGenerator { dependency.dateGenerator }
}

public protocol CalendarBuildable: Buildable {
    func build(withListener listener: CalendarListener) -> ViewableRouting
}

class CalendarBuilder: Builder<CalendarDependency>, CalendarBuildable {
    
    public override init(dependency: CalendarDependency) {
      super.init(dependency: dependency)
    }
    
    public func build(withListener listener: CalendarListener) -> ViewableRouting {
        let component = CalendarComponent(dependency: dependency)
        let viewController = CalendarViewController()
        let interactor = CalendarInteractor(presenter: viewController, dateGenerator: dependency.dateGenerator) // AppRoot에서 dateGenerator 생성
        interactor.listener = listener

        /// Calendar child Builder
        let transactionInputBuilder = TransactionInputBuilder(dependency: component)
        let transactionDetailBuilder = TransactionDetailBuilder(dependency: component)
        
        return CalendarRouter(interactor: interactor,
                              viewController: viewController,
                              transactionInputBuilder: transactionInputBuilder,
                              transactionDetailBuilder: transactionDetailBuilder)
    }
}
