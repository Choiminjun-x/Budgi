//
//  UIButton+Extension.swift
//  Budgi
//
//  Created by 최민준 on 1/24/26.
//

import UIKit
import Combine

private var tapPublisherKey: UInt8 = 0

extension UIButton {
    
    var tapPublisher: AnyPublisher<Void, Never> {
        if let publisher = objc_getAssociatedObject(self, &tapPublisherKey) as? PassthroughSubject<Void, Never> {
            return publisher.eraseToAnyPublisher()
        }

        let subject = PassthroughSubject<Void, Never>()
        addTargetClosure { _ in
            subject.send(())
        }
        objc_setAssociatedObject(self, &tapPublisherKey, subject, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        return subject.eraseToAnyPublisher()
    }

    private func addTargetClosure(_ closure: @escaping (UIButton) -> Void) {
        let sleeve = ClosureSleeve(closure)
        addTarget(sleeve, action: #selector(ClosureSleeve.invoke(_:)), for: .touchUpInside)
        objc_setAssociatedObject(self, String(format: "[%d]", arc4random()), sleeve, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
    }
}

private class ClosureSleeve {
    let closure: (UIButton) -> Void

    init(_ closure: @escaping (UIButton) -> Void) {
        self.closure = closure
    }

    @objc func invoke(_ sender: UIButton) {
        closure(sender)
    }
}
