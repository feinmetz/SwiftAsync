# SwiftAsync 1.1.0
SwiftAsync is a utility module which provides functions for working with asynchronous Swift. Inspired by AsyncJS.

## Usage

### Parallel call
Applies the function iteratee to each item in coll, in parallel.

```swift
func example() {
    let items: Array = [100, 200, 300, 400]

    SwiftAsync.each(items) {
        [unowned self] item, callback in
        self.download {
            callback()
        }
    }
    .done {
        print("each done. downloads finished")
    }
    .empty {
        print("items are empty")
    }
}

func simulDownload(completion: @escaping() -> ()) {
    let randomNum: UInt32 = arc4random_uniform(5) // random integer between 0 and 5
    let randomTime: TimeInterval = TimeInterval(randomNum)
    Timer.scheduledTimer(withTimeInterval: randomTime, repeats: false) { timer in
        completion()
    }
}    
```

Possible output:
```swift
400
200
300
100
each done. downloads finished
```

### Series call
The same as each but runs only a single async operation at a time.

```swift
let items: Array = [100, 200, 300, 400]

SwiftAsync.eachSeries(items) {
    [unowned self] item, callback in
    self.download {
        callback()
    }
}
.done {
    print("each done. downloads finished")
}
.empty {
    print("items are empty")
}
```

Output:
```swift
100
200
300
400
each done. downloads finished
```

## License

SwiftAsync is released under the MIT license. See LICENSE for details.
