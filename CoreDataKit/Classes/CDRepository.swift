//
//  CDRepository.swift
//  CoreDataKit
//
//  Created by Bogdan Filippov on 9/9/23.
//

import CoreData

internal class CDRepository<T: NSManagedObject> {
    
    internal let stack: CDStack
    internal let sortDescriptor: CDSortDescriptor
    
    internal var entityName: String {
        return T.className()
    }
    internal var mainContext: NSManagedObjectContext {
        return stack.mainContext
    }
    internal var backgroundContext: NSManagedObjectContext {
        return stack.backgroundContext
    }
    
    internal init(modelName: String, storeURL: URL? = nil, sortDescriptor: CDSortDescriptor) {
        self.stack = CDStack.get(CDConfiguration(modelName: modelName, storeURL: storeURL, errorHandler: nil))
        self.sortDescriptor = sortDescriptor
    }
    
    internal func context(isMainContext: Bool) -> NSManagedObjectContext {
        return isMainContext ? mainContext : backgroundContext
    }
    
    internal func saveChanges(isMainContext: Bool) throws {
        let context = context(isMainContext: isMainContext)
        if context.hasChanges {
            try context.save()
        }
    }
    
    internal func createNewObject(isMainContext: Bool) -> T {
        let context = context(isMainContext: isMainContext)
        return T(context: context)
    }
    
    internal func fetchAllObjects(sortedBy sortDescriptor: CDSortDescriptor? = nil, with pagination: CDPagination? = nil, isMainContext: Bool) throws -> [T] {
        let fetchRequest = createFetchRequest(sortedBy: sortDescriptor, with: pagination)
        return try fetch(using: fetchRequest, isMainContext: isMainContext)
    }
    
    internal func countAllObjects(sortedBy sortDescriptor: CDSortDescriptor? = nil, isMainContext: Bool) throws -> Int {
        let context = context(isMainContext: isMainContext)
        let fetchRequest = createFetchRequest(sortedBy: sortDescriptor)
        return try context.count(for: fetchRequest)
    }
    
    internal func searchObjects(usingQuery query: String, sortedBy sortDescriptor: CDSortDescriptor? = nil, with pagination: CDPagination? = nil, isMainContext: Bool) throws -> [T] {
        let predicate = NSPredicate(format: query)
        return try searchObjects(usingPredicate: predicate, sortedBy: sortDescriptor, with: pagination, isMainContext: isMainContext)
    }
    
    internal func searchObjects(usingPredicate predicate: NSPredicate, sortedBy sortDescriptor: CDSortDescriptor? = nil, with pagination: CDPagination? = nil, isMainContext: Bool) throws -> [T] {
        let fetchRequest = createFetchRequest(sortedBy: sortDescriptor, with: pagination)
        fetchRequest.predicate = predicate
        return try fetch(using: fetchRequest, isMainContext: isMainContext)
    }
    
    internal func delete(object: T) throws {
        object.managedObjectContext?.delete(object)
        try saveChanges(isMainContext: object.managedObjectContext == mainContext)
    }
    
    internal func deleteAllObjects(isMainContext: Bool) throws {
        let context = context(isMainContext: isMainContext)
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        try context.execute(deleteRequest)
        try saveChanges(isMainContext: isMainContext)
    }
    
    internal func objectExists(withPredicate predicate: NSPredicate, isMainContext: Bool) throws -> Bool {
        let fetchRequest = createFetchRequest()
        fetchRequest.predicate = predicate
        fetchRequest.fetchLimit = 1
        return try fetch(using: fetchRequest, isMainContext: isMainContext).count > 0
    }
    
    private func fetch(using request: NSFetchRequest<NSFetchRequestResult>, isMainContext: Bool) throws -> [T] {
        let context = context(isMainContext: isMainContext)
        return try context.fetch(request) as? [T] ?? []
    }
    
    private func createFetchRequest(sortedBy sortDescriptor: CDSortDescriptor? = nil, with pagination: CDPagination? = nil) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let sortDescriptor = NSSortDescriptor(key: sortDescriptor?.key ?? self.sortDescriptor.key, ascending: sortDescriptor?.ascending ?? self.sortDescriptor.ascending)
        fetchRequest.sortDescriptors = [sortDescriptor]
        fetchRequest.fetchLimit = pagination?.limit ?? 0
        fetchRequest.fetchOffset = pagination?.offset ?? 0
        return fetchRequest
    }
    
}
