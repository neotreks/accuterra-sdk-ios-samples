//
//  Synchronize.swift
//  DemoApp
//
//  Created by Rudolf Kopřiva on 02/03/2020.
//  Copyright © 2020 NeoTreks. All rights reserved.
//

import Foundation

///
/// Blocks all threads using lock, allows re-entry in case called again on the same thread
///
func synchronized(lock: AnyObject, closure:()->()) {
    objc_sync_enter(lock)
    closure()
    objc_sync_exit(lock);
}

///
/// Blocks all threads using lock, allows re-entry in case called again on the same thread
///  - returns: T
///
func synchronized<T>( lock: AnyObject, body: () throws -> T) rethrows -> T {
    objc_sync_enter(lock)
    defer { objc_sync_exit(lock) }
    return try body()
}

///
/// Ensures that block is called on main thread
///
func executeBlockOnMainThread(_ block:@escaping () -> Void) {
    if Thread.isMainThread {
        block()
    } else {
        DispatchQueue.main.sync {
            block()
        }
    }
}
