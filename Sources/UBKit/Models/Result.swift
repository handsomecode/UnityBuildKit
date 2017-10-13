//
//  Result.swift
//  UEKit
//
//  Created by Eric Miller on 10/11/17.
//

import Foundation

public enum Result: Equatable {
    case success
    case failure(Error?)

    var error: Error? {
        switch self {
        case .success:
            return nil
        case .failure(let err):
            return err
        }
    }
}

public func ==(lhs: Result, rhs: Result) -> Bool {
    switch (lhs, rhs) {
    case (.success, .success):
        return true
    case (.failure(_), .failure(_)):
        return true
    default:
        return false
    }
}
