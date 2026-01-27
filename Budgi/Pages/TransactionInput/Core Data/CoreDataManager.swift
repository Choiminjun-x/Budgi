//
//  CoreDataManager.swift
//  Budgi
//
//  Created by 최민준 on 1/26/26.
//

import CoreData

final class CoreDataManager {
    
    static let shared = CoreDataManager()
    
    private let container: NSPersistentContainer
    
    var context: NSManagedObjectContext {
        self.container.viewContext
    }
    
    private init() {
        self.container = NSPersistentContainer(name: "BudgiModel")
        self.container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("❌ CoreData load error: \(error)")
            }
        }
    }
    
    func saveContext() {
        guard self.context.hasChanges else { return }
        do {
            try self.context.save()
        } catch {
            print("❌ Save failed: \(error)")
        }
    }
}

extension CoreDataManager {
    
    func fetchTransactions(for month: Date) -> [Transaction] {
        let calendar = Calendar.current
        guard let startOfMonth = calendar.dateInterval(of: .month, for: month)?.start,
              let endOfMonth = calendar.date(byAdding: .month, value: 1, to: startOfMonth) else {
            return []
        }

        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfMonth as NSDate, endOfMonth as NSDate)
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]

        do {
            return try context.fetch(request)
        } catch {
            print("❌ Fetch failed: \(error)")
            return []
        }
    }
    
    /// id로 단건 삭제
    @discardableResult
    func deleteTransaction(id: UUID) -> Bool {
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()
        request.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        request.fetchLimit = 1
        do {
            if let obj = try context.fetch(request).first {
                context.delete(obj)
                try context.save()
                return true
            }
        } catch {
            print("❌ Delete by id failed: \(error)")
        }
        return false
    }
    
    /// 특정 날짜 모든 내역 삭제
    func deleteTransactions(for date: Date) {
        let context = CoreDataManager.shared.context
        let request: NSFetchRequest<Transaction> = Transaction.fetchRequest()

        let calendar = Calendar.current
        let startOfDay = calendar.startOfDay(for: date)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!

        request.predicate = NSPredicate(format: "date >= %@ AND date < %@", startOfDay as NSDate, endOfDay as NSDate)

        do {
            let results = try context.fetch(request)
            for transaction in results {
                context.delete(transaction)
            }
            try context.save()
            print("🗑️ \(results.count)개의 트랜잭션 삭제됨")
        } catch {
            print("❌ 삭제 실패: \(error.localizedDescription)")
        }
    }
}
