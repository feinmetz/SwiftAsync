//
//  SwiftAsync.swift
//
//  Created by Frank Hinkel on 10.11.16.
//  Copyright © 2016 Frank Hinkel. All rights reserved.
//

import Foundation

open class SwiftAsync {
    // each item in parallel
    public static func each(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> (), done: @escaping() -> ()) {
        each(items!, iteratee: iteratee, done: done, empty: nil)
    }
    public static func each(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> (), done: @escaping() -> (), empty: (() -> Void)? = nil) {
        if items != nil && !items!.isEmpty {
            each(items!, series: false, iteratee: iteratee, done: done)
        } else {
            empty?()
        }
    }
    
    // each item in series
    public static func eachSeries(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> (), done: @escaping() -> ()) {
        eachSeries(items!, iteratee: iteratee, done: done, empty: nil)
    }
    public static func eachSeries(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> (), done: @escaping() -> (), empty: (() -> Void)? = nil) {
        if items != nil && !items!.isEmpty {
            each(items!, series: true, iteratee: iteratee, done: done)
        } else {
            empty?()
        }
    }
    
    // internal function
    private static func each(_ items: [Any], series: Bool = false, iteratee: @escaping(Any, @escaping() -> ()) -> (), done: @escaping() -> ()) {
        var isDone: Bool = false
        var running: Int = 0
        var next: Int = -1
        
        func iterateeCallback() {
            running -= 1
            if (isDone && running <= 0) {
                return done()
            }
            if series {
                replenish()
            }
        }
        
        func nextElem() -> Any? {
            next += 1
            if (next < items.count) {
                return items[next]
            }
            return nil
        }
        
        func replenish () {
            let elem = nextElem()
            if (elem == nil) {
                isDone = true
                if (running <= 0) {
                    done()
                }
                return
            }
            running += 1
            iteratee(items[next], iterateeCallback)
        }
        if series {
            replenish()
        } else {
            while (running <= items.count && !isDone) {
                replenish()
            }
        }
    }
}
