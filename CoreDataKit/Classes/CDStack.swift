//
//  CDStack.swift
//  CoreDataKit
//
//  Created by Bogdan Filippov on 9/9/23.
//

import CoreData

internal class CDStack {
    
    // MARK: - Static Methods
    
    internal static func get(_ configuration: CDConfiguration) -> CDStack {
        if let stack = initiatedStacks.first(where: { $0.configuration.modelName == configuration.modelName && $0.configuration.storeURL == configuration.storeURL }) {
            return stack
        } else {
            let stack = CDStack(configuration: configuration)
            initiatedStacks.append(stack)
            return stack
        }
    }
    internal static func list() -> [CDStack] {
        return initiatedStacks
    }
    internal static func saveContexts() {
        list().forEach {
            $0.saveMainContext()
            $0.saveBackgroundContext()
        }
    }
    
    // MARK: - Static Properties
    
    private static var initiatedStacks: [CDStack] = []
    
    // MARK: - Properties
    
    internal let configuration: CDConfiguration
    
    // MARK: - Container Properties
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: configuration.modelName)
        configureContainer(container)
        return container
    }()
    
    // MARK: - Context Properties
    
    internal lazy var mainContext: NSManagedObjectContext = {
        let context = persistentContainer.viewContext
        configure(context: context)
        return context
    }()
    
    internal lazy var backgroundContext: NSManagedObjectContext = {
        let context = persistentContainer.newBackgroundContext()
        configure(context: context, isBackground: true)
        return context
    }()
    
    // MARK: - Private Dynamical Properties
    
    private var storeUrl: URL {
        return configuration.storeURL ?? defaultStoreUrl
    }
    
    private var defaultStoreUrl: URL {
        let applicationDocumentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).last!
        return applicationDocumentsDirectory.appendingPathComponent("\(configuration.modelName).sqlite")
    }
    
    private var storeDescription: NSPersistentStoreDescription {
        let description = NSPersistentStoreDescription(url: storeUrl)
        description.shouldAddStoreAsynchronously = false
        description.shouldMigrateStoreAutomatically = true
        description.shouldInferMappingModelAutomatically = true
        return description
    }
    
    // MARK: - Initialization
    
    private init(configuration: CDConfiguration) {
        self.configuration = configuration
    }
    
    // MARK: - Public Methods
    
    internal func saveMainContext() {
        save(context: mainContext)
    }
    
    internal func saveBackgroundContext() {
        save(context: backgroundContext)
    }
    
    internal func save(context: NSManagedObjectContext) {
        context.performAndWait {
            if context.hasChanges {
                do {
                    try context.save()
                } catch {
                    configuration.errorHandler?(error)
                }
            }
        }
    }
    
    // MARK: - Configure Methods
    
    private func configureContainer(_ container: NSPersistentContainer) {
        container.persistentStoreDescriptions = [storeDescription]
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error {
                self.configuration.errorHandler?(error)
            }
        }
    }
    
    private func configure(context: NSManagedObjectContext, isBackground: Bool = false) {
        context.mergePolicy = NSMergePolicy(merge: .overwriteMergePolicyType)
        if isBackground {
            context.automaticallyMergesChangesFromParent = true
        }
    }
    
}
