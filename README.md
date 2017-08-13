# ConNews

A small demo app demonstrating the use of 
[NSOperationQueue](https://developer.apple.com/documentation/foundation/operationqueue) in 
Swift to parallelize network requests for a better user experience. Some features of 
[Grand Central Dispatch](https://developer.apple.com/documentation/dispatch) are also utilized.

This app was created to accompany a conference talk entitled: "Threads, Queues, and Things
to Come; The Present and Future of Concurrency in Swift". This talk will be presented
at [360iDev](https://360idev.com/) in Denver, CO on Tuesday, August 15, 2017.

## What is the app?

This demo app implements a simple HackerNews client. The HackerNews API provides an
endpoint for loading the list of top 500 stories on the site. It returns a list of
unique Ids. Each Id must be used in another endpoint to fetch the story data
itself. Additionally, the app shows the [Favicon](https://en.wikipedia.org/wiki/Favicon) 
of each site next to the story. The path of the icon must be derived from the
data fetched with the story.

## What does it demonstrate?

Several useful features of `NSOperationQueue` are demonstrated:

 1. Basic Queueing
 2. Dependent Operations
 3. Pausing/Resuming a Queue
 
Additionally, Grand Central Dispatch (GCD) is utilized to:

 1. Protect Shared Mutable State
 2. Serialize a Network Callback

### NSOperationQueue

`NSOperationQueue` is an Objective-C class that bridges to Swift as simply `OperationQueue`.
It is a powerful tool for queuing work to be done asynchronously without much effort. In this
demo, we demonstrate:

#### Basic Queuing

Each request to fetch a story is implemented as an `NSOperation` and added to
an `NSOperationQueue`. As each request completes, its data is used to update
the UI.

#### Dependent Operations

Fetching the Favicon for each website is added as a dependency of the story
fetch. It utilizes the data from the story to derive the path to the Favicon.

#### Pausing/Resuming a Queue

If the user taps a cell, to load a story in `SafariViewController`, we pause
any stories and icons that are still loading in the background.

### Grand Central Dispatch

Grand Central Dispatch, called GCD or sometimes `libdispatch`, is a C library
which bridges into Swift as normal types. While *slightly* more cumbersome
than `NSOperationQueue`, it is still powerful and awesome useful in tandem
with a full blown operation queue. In this demo, we do just that, using GCD to:

#### Protect Shared State

A serial Grand Central Dispatch queue is used to protect access to the shared
list of stories as each fetch request completes. Mutating an Array in Swift is
not an atomic operation. A serial queue can be used much he same way a traditional
Lock or call to `@synchronize` would be in Objective-C.

#### Serialize a Network Callback

Our fetch request occurs in the `main()` method of our `NSOperation` subclass. We
don't want the operation to return until the request is complete. We use a GCD
`DispatchGroup` to block the operation until the data has been acquired.

## Resources

Go deeper in your understanding of concurrency in Swift.

 * [OperationQueue](https://developer.apple.com/documentation/foundation/operationqueue): 
   Apple's documentation for `NSOperationQueue` in Swift
 * [Dispatch](https://developer.apple.com/documentation/dispatch): Apple's documentation
   for Grand Central Dispatch in Swift
 * [NSOperation on NSHipster](http://nshipster.com/nsoperation/): A great introduction to
   using Operations, with some GCD mixed in
 * [All about Concurrency in Swift](https://www.uraimo.com/2017/05/07/all-about-concurrency-in-swift-1-the-present/):
   An in-depth, two part discussion of concurrency in Swift by [Umberto Raimondi](https://www.uraimo.com/about/).
 * [Green Threads Explained](https://c9x.me/articles/gthreads/intro.html): An introduction to the concept of
   Green Threads and why they are useful.
 * [Promise](https://github.com/khanlou/Promise): A library implementing Promises in Swift by 
   [@khanlou](https://twitter.com/khanlou)
 * [The Actor Model in 10 Minutes](http://www.brianstorti.com/the-actor-model/): An introduction to The
   Actor Model
