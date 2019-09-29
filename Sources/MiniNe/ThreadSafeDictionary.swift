//
//  ThreadSafeDictionary.swift
//  
//
//  Created by Kevin Chen on 9/28/19.
//

import Foundation

public class ThreadSafeDictionary<Key: Hashable, Value> {
    private var dictionary: [Key: Value] = [:]
    
    /// Used because multiple threads could access or modify the tasks dictionary.
    /// Use .sync for getting and .async(flags: .barrier) for setting for optimal performance.
    /// Sync for reading will ensure all reading happens each other.
    /// async with barrier will ensure all reading is done before writing is done and pending reading will start after block
    /// Speed diff on different reader/writier locks: https://medium.com/@dmytro.anokhin/concurrency-in-swift-reader-writer-lock-4f255ae73422
    private let queue = DispatchQueue(label: "ThreadSafeDictionary", attributes: .concurrent)
    
    public subscript(key: Key) -> Value? {
        get {
            var value: Value?
            queue.sync {
                value = dictionary[key]
            }
            
            return value
        }
        set {
            queue.async(flags: .barrier) {
                self.dictionary[key] = newValue
            }
        }
    }
}
