"
#Future
A future represents an asynchronous computation.
A future is a value that may not have finished computing yet. This kind of ""asynchronous value"" makes it possible for a thread to continue doing useful work while it waits for the value to become available.

###The poll method
The core method of future, {{gtMethod:TAsyncFuture>>#poll:}}, attempts to resolve the future into a final value. This method does not block if the value is not ready. Instead, the current task is scheduled to be woken up when it's possible to make further progress by polling again. The context passed to the poll method can provide a Waker, which is a handle for waking up the current task.
When using a future, you generally won't call poll directly, but instead {{gtMethod:TAsyncFuture>>#await}} the value.
"
Trait {
	#name : #TAsyncFuture,
	#category : #'Futures-Base - Futures'
}

{ #category : #'api - future' }
TAsyncFuture >> asAsyncFuture [
	^ self
]

{ #category : #'api - future' }
TAsyncFuture >> asAsyncPromise [
	^ AsyncFuturePromise new future: self
]

{ #category : #'api - future' }
TAsyncFuture >> asAsyncStream [
	^ AsyncOnceStream forFuture: self
]

{ #category : #'api - future copy' }
TAsyncFuture >> asyncSimilarCopy [
	"Answer another future of the same type that is not yet polled.
	This is different from #copy, which would potentially create a copy of the future
	in the same state as the copied future"
	<return: #TAsyncFuture>

	^ self shallowCopy postSimilarCopy
]

{ #category : #'api - future' }
TAsyncFuture >> await [
	^ AsyncTaskItFutureTask forAsyncFuture: self
]

{ #category : #'api - testing' }
TAsyncFuture >> isAsyncFuture [
	^ true
]

{ #category : #'api - testing' }
TAsyncFuture >> isReadyFuture [
	"Return true if a future is a ready future, meaning that the value can be taken synchronously"
	<return: #Boolean>

	^ false
]

{ #category : #'api - future' }
TAsyncFuture >> map: aBlock [
	^ AsyncMapFuture future: self mapBlock: aBlock
]

{ #category : #'api - future' }
TAsyncFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ self explicitRequirement
]

{ #category : #'api - future copy' }
TAsyncFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
]

{ #category : #'api - future' }
TAsyncFuture >> wait [
	| aSemaphore anAwaitResult anAwaitError |
	
	aSemaphore := Semaphore new.
	
	self await
		onSuccessDo: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ];
		onFailureDo: [ :anError |
			anAwaitError := anError freeze.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ AsyncFutureError signalForException: anAwaitError ].
	^ anAwaitResult
]
