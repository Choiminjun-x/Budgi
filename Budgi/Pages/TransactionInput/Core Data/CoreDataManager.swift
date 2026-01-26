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
}
