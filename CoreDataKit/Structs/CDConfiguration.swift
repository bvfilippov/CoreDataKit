//
//  CDConfiguration.swift
//  CoreDataKit
//
//  Created by Bogdan Filippov on 9/9/23.
//

import Foundation

internal struct CDConfiguration {
    internal let modelName: String
    internal let storeURL: URL?
    internal let errorHandler: ((Error) -> Void)?
}
