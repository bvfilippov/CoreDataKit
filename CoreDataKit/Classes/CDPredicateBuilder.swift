//
//  CDPredicateBuilder.swift
//  CoreDataKit
//
//  Created by Bogdan Filippov on 9/10/23.
//

import CoreData

public class CDPredicateBuilder {
    
    // MARK: - Private Properties
    
    private var predicateComponents: [String] = []
    private var arguments: [Any] = []
    
    // MARK: - Public Methods
    
    @discardableResult
    public func and() -> Self {
        return appendLogicalOperator(.and)
    }
    
    @discardableResult
    public func or() -> Self {
        return appendLogicalOperator(.or)
    }
    
    @discardableResult
    public func beginGroup() -> Self {
        predicateComponents.append("(")
        return self
    }
    
    @discardableResult
    public func endGroup() -> Self {
        predicateComponents.append(")")
        return self
    }
    
    @discardableResult
    public func addCondition<T>(_ attribute: String, operation: CDPredicateOperator, value: T) -> Self {
        predicateComponents.append("\(attribute) \(operation.rawValue) %@")
        arguments.append(value)
        return self
    }
    
    @discardableResult
    public func between<T>(_ attribute: String, range: Range<T>) -> Self {
        predicateComponents.append("\(attribute) BETWEEN {%@, %@}")
        arguments.append(contentsOf: [range.lowerBound, range.upperBound])
        return self
    }
    
    public func build() -> NSPredicate? {
        guard isValidPredicate else { return nil }
        let predicateString = predicateComponents.joined(separator: " ")
        return NSPredicate(format: predicateString, argumentArray: arguments)
    }
    
    // MARK: - Private Methods
    
    @discardableResult
    private func appendLogicalOperator(_ logicalOperator: CDPredicateLogicalOperator) -> Self {
        if !predicateComponents.isEmpty {
            predicateComponents.append(logicalOperator.rawValue)
        }
        return self
    }
    
    private var isValidPredicate: Bool {
        let trimmedComponents = predicateComponents.joined(separator: " ").trimmingCharacters(in: .whitespaces)
        return !(trimmedComponents.hasSuffix(CDPredicateLogicalOperator.and.rawValue) ||
                 trimmedComponents.hasSuffix(CDPredicateLogicalOperator.or.rawValue) ||
                 trimmedComponents.first != "(" && trimmedComponents.last != ")")
    }
    
}
