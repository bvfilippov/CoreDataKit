//
//  CDEntityManager.swift
//  CoreDataKit
//
//  Created by Bogdan Filippov on 9/10/23.
//

import CoreData

public class CDEntityManager<T: NSManagedObject> {
    
    private let repository: CDRepository<T>
    
    init(modelName: String, storeURL: URL? = nil, sortDescriptor: CDSortDescriptor) {
        repository = CDRepository(modelName: modelName, storeURL: storeURL, sortDescriptor: sortDescriptor)
    }
    
    public func saveChanges(isMainContext: Bool, didPerformHandler: (() -> ())? = nil) async throws {
        let context = repository.context(isMainContext: isMainContext)
        if let didPerformHandler = didPerformHandler {
            try await context.perform {
                try self.repository.saveChanges(isMainContext: isMainContext)
                didPerformHandler()
            }
        } else {
            try context.performAndWait {
                try repository.saveChanges(isMainContext: isMainContext)
            }
        }
    }
    
    public func createNewObject(isMainContext: Bool) -> T {
        let context = repository.context(isMainContext: isMainContext)
        return context.performAndWait {
            return T(context: context)
        }
    }
    
    public func createNewObject(isMainContext: Bool, didPerformHandler: ((T) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            didPerformHandler?(T(context: context))
        }
    }
    
    public func fetchAllObjects(with pagination: CDPagination?, isMainContext: Bool) throws -> [T] {
        let context = repository.context(isMainContext: isMainContext)
        return try context.performAndWait {
            return try repository.fetchAllObjects(with: pagination, isMainContext: isMainContext)
        }
    }
    
    public func fetchAllObjects(with pagination: CDPagination?, isMainContext: Bool, didPerformHandler: (([T]?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                let entries = try self.repository.fetchAllObjects(with: pagination, isMainContext: isMainContext)
                didPerformHandler?(entries, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func countAllObjects(sortedBy sortDescriptor: CDSortDescriptor?, isMainContext: Bool) throws -> Int {
        let context = repository.context(isMainContext: isMainContext)
        return try context.performAndWait {
            return try repository.countAllObjects(sortedBy: sortDescriptor, isMainContext: isMainContext)
        }
    }
    
    public func countAllObjects(sortedBy sortDescriptor: CDSortDescriptor?, isMainContext: Bool, didPerformHandler: ((Int?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                let count = try self.repository.countAllObjects(sortedBy: sortDescriptor, isMainContext: isMainContext)
                didPerformHandler?(count, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func searchObjects(usingQuery query: String, with pagination: CDPagination?, isMainContext: Bool) throws -> [T] {
        let context = repository.context(isMainContext: isMainContext)
        return try context.performAndWait {
            return try repository.searchObjects(usingQuery: query, with: pagination, isMainContext: isMainContext)
        }
    }
    
    public func searchObjects(usingQuery query: String, with pagination: CDPagination?, isMainContext: Bool, didPerformHandler: (([T]?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                let entries = try self.repository.searchObjects(usingQuery: query, with: pagination, isMainContext: isMainContext)
                didPerformHandler?(entries, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func searchObjects(usingPredicate predicate: NSPredicate, with pagination: CDPagination?, isMainContext: Bool) throws -> [T] {
        let context = repository.context(isMainContext: isMainContext)
        return try context.performAndWait {
            return try repository.searchObjects(usingPredicate: predicate, with: pagination, isMainContext: isMainContext)
        }
    }
    
    public func searchObjects(usingPredicate predicate: NSPredicate, with pagination: CDPagination?, isMainContext: Bool, didPerformHandler: (([T]?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                let entries = try self.repository.searchObjects(usingPredicate: predicate, with: pagination, isMainContext: isMainContext)
                didPerformHandler?(entries, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func delete(object: T, isMainContext: Bool) throws {
        let context = repository.context(isMainContext: isMainContext)
        try context.performAndWait {
            try repository.delete(object: object)
        }
    }
    
    public func delete(object: T, isMainContext: Bool, didPerformHandler: ((Bool?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                try self.repository.delete(object: object)
                didPerformHandler?(true, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func deleteAllObjects(isMainContext: Bool) throws {
        let context = repository.context(isMainContext: isMainContext)
        try context.performAndWait {
            try repository.deleteAllObjects(isMainContext: isMainContext)
        }
    }
    
    public func deleteAllObjects(isMainContext: Bool, didPerformHandler: ((Bool?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                try self.repository.deleteAllObjects(isMainContext: isMainContext)
                didPerformHandler?(true, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
    public func objectExists(withPredicate predicate: NSPredicate, isMainContext: Bool) throws -> Bool {
        let context = repository.context(isMainContext: isMainContext)
        return try context.performAndWait {
            return try repository.objectExists(withPredicate: predicate, isMainContext: isMainContext)
        }
    }
    
    public func objectExists(withPredicate predicate: NSPredicate, isMainContext: Bool, didPerformHandler: ((Bool?, Error?) -> ())? = nil) {
        let context = repository.context(isMainContext: isMainContext)
        context.perform {
            do {
                let status = try self.repository.objectExists(withPredicate: predicate, isMainContext: isMainContext)
                didPerformHandler?(status, nil)
            } catch {
                didPerformHandler?(nil, error)
            }
        }
    }
    
}
