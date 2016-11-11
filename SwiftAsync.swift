//
//  SwiftAsync.swift
//
//  Created by Frank Hinkel on 10.11.16.
//  Copyright © 2016 Frank Hinkel. All rights reserved.
//

import Foundation

open class SwiftAsync {
    var items: [Any]?
    public var doneBlock: (()->())? = nil

    // each item in parallel
    public static func each(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> ()) -> SwiftAsync {
        return each(items, series: false, iteratee: iteratee)
    }
    
    // each item in series
    public static func eachSeries(_ items: [Any]?, iteratee: @escaping(Any, @escaping() -> ()) -> ()) -> SwiftAsync {
        return each(items, series: true, iteratee: iteratee)
    }
    
    private static func each(_ items: [Any]?, series: Bool = false, iteratee: @escaping(Any, @escaping() -> ()) -> ()) -> SwiftAsync {
        let async = SwiftAsync()
        
        if items != nil && !items!.isEmpty {
            async.items = items
            DispatchQueue.main.async {
                async.each(items!, series: series, iteratee: iteratee)
            }
        }
        
        return async
    }
    
    // internal function
    private func each(_ items: [Any], series: Bool = false, iteratee: @escaping(Any, @escaping() -> ()) -> ()) {
        var isDone: Bool = false
        var running: Int = 0
        var next: Int = -1
        
        func iterateeCallback() {
            running -= 1
            if (isDone && running <= 0) {
                self.doneBlock?()
                return
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
                    self.doneBlock?()
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
    
    @discardableResult
    public func done(_ completion: @escaping() -> ()) -> SwiftAsync {
        self.doneBlock = completion
        return self
    }
    
    @discardableResult
    public func empty(_ completion: @escaping() -> ()) -> SwiftAsync {
        if items == nil ||  (items != nil && items!.isEmpty) {
            completion()
        }
        return self
    }
}
