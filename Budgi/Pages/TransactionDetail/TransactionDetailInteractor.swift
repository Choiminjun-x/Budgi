//
//  TransactionDetailInteractor.swift
//  Budgi
//
//  Created by 최민준(Minjun Choi) on 1/28/26.
//

import Foundation
import UIKit
import RIBs

protocol TransactionDetailRouting: ViewableRouting {
    //    func attachTodoListDetail()
    //    func detachTodoListDetail()
}

protocol TransactionDetailPresentable: Presentable {
    var listener: TransactionDetailPresentableListener? { get set }
    func presentDetail(_ info: TransactionDetailViewModel.Detail)
}

public protocol TransactionDetailListener: AnyObject {
    func transactionDetailDidClose()
}

class TransactionDetailInteractor: PresentableInteractor<TransactionDetailPresentable>, TransactionDetailInteractable, TransactionDetailPresentableListener {
    
    var router: TransactionDetailRouting?
    var listener: TransactionDetailListener?
    private let transactionId: UUID
    
    init(presenter: TransactionDetailPresentable, transactionId: UUID) {
        self.transactionId = transactionId
        super.init(presenter: presenter)
        presenter.listener = self
    }
    
    override func didBecomeActive() {
        super.didBecomeActive()
        
        self.requestPageInfo()
    }
    
    func requestPageInfo() {
        guard let tx = CoreDataManager.shared.fetchTransaction(id: transactionId) else { return }
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        let text = formatter.string(from: NSNumber(value: abs(tx.amount))) ?? "0"
        let amountText = (tx.amount < 0 ? "-" : "+") + text
        let tint: UIColor = tx.amount < 0 ? .systemBlue : .systemRed
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "ko_KR")
        dateFormatter.dateFormat = "yyyy년 MM월 dd일"
        let dateText = tx.date.map { dateFormatter.string(from: $0) } ?? ""
        let info = TransactionDetailViewModel.Detail(
            categoryName: self.categoryName(for: tx.category),
            amountText: amountText,
            amountTint: tint,
            dateText: dateText,
            memoText: tx.memo
        )
        self.presenter.presentDetail(info)
    }
    
    // 닫기 버튼
    func didTapClose() {
        self.listener?.transactionDetailDidClose()
    }
}

private extension TransactionDetailInteractor {
    func categoryName(for id: String?) -> String {
        guard let id = id else { return "미분류" }
        switch id {
        case "food": return "식비"
        case "transport": return "교통"
        case "hobby": return "취미"
        case "shopping": return "쇼핑"
        case "life": return "생활"
        case "health": return "의료"
        case "etc_exp": return "기타"
        case "salary": return "급여"
        case "bonus": return "보너스"
        case "gift": return "용돈"
        case "etc_inc": return "기타"
        case "uncat": return "미분류"
        default: return id
        }
    }
}
