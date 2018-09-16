//
//  Result.swift
//  SampleProject
//
//  Created by Kirby on 6/19/17.
//  Copyright © 2017 Kirby. All rights reserved.
//

import Foundation

// A generic result for success or failure
public enum Result<T, Error: Swift.Error> {
    case success(T)
    case failure(Error)
    
    public init(value: T) {
        self = .success(value)
    }
    
    public init(error: Error) {
        self = .failure(error)
    }
}
