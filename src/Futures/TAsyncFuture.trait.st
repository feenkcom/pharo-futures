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
	^ self await
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
	"Execute the future asynchronously and return a promise that will be resolved with the future's result"
	<return: #TAsyncPromise>
	
	^ self await: AsyncFutureExecutionConfiguration default
]

{ #category : #'api - future' }
TAsyncFuture >> await: anExecutionSpecification [
	"Execute the future asynchronously and return a promise that will be resolved with the future's result"
	<return: #TAsyncPromise>
	| aPromise |

	aPromise := AsyncFuturePromise new
		priority: anExecutionSpecification priority;
		group: anExecutionSpecification group;
		errorHandler: anExecutionSpecification errorHandler;
		maxAmountOfWorkers: anExecutionSpecification maxAmountOfWorkers;
		future: self.
		
	AsyncFutureThreadPool current schedule: aPromise.

	^ aPromise
]

{ #category : #'api - future' }
TAsyncFuture >> awaitWithPassExceptionHandler [
	"Execute the future asynchronously by allowing error to pass and raise a debugger if not caught."
	<return: #TAsyncPromise>
	
	^ self await: (AsyncFutureExecutionConfiguration default
		errorHandler: AsyncPassExceptionHandler new)
]

{ #category : #'api - future' }
TAsyncFuture >> delayed: aDuration [
	^ AsyncDelayedFuture forFuture: self delay: aDuration
]

{ #category : #'api - future' }
TAsyncFuture >> flatten [
	"Flatten the execution of this future when the output of this future is itself another future.
	This can be useful when combining futures together to flatten the computation out the final result."
	<return: #TAsyncFuture>

	^ AsyncFlattenFuture forFuture: self
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
	"Map this future's output to a different object.
	This function is similar to the `Collection>>#collect:` where it will change the type of the underlying future.
	This is useful to chain along a computation once a future has been resolved."
	<return: #TAsyncFuture>

	^ AsyncMapFuture future: self mapBlock: aBlock
]

{ #category : #'api - future' }
TAsyncFuture >> on: anException do: anExceptionHandler [
	^ AsyncErrorHandlingFuture
		future: self
		on: anException
		do: anExceptionHandler
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
TAsyncFuture >> then: aBlock [
	"Chain on a computation for when a future finished, passing the result of the future to the provided block closure.
	The returned value of the closure must implement the `TAsyncFuture` trait or be converted to a future with #asAsyncFuture
	and can represent some more work to be done before the composed future is finished.
   The given block closure is only run *after* successful completion of the `self` future."
	<return: #TAsyncFuture>

	^ (self map: aBlock) flatten
]

{ #category : #'api - future' }
TAsyncFuture >> wait [
	| aSemaphore anAwaitResult anAwaitError |
	
	aSemaphore := Semaphore new.
	
	self await
		then: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ]
		otherwise: [ :anError |
			anAwaitError := anError freeze.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ AsyncFutureExecutionError signalForException: anAwaitError ].
	^ anAwaitResult
]
