Trait {
	#name : #TAsyncPromise,
	#category : #'Futures-Base - Promises'
}

{ #category : #converting }
TAsyncPromise >> asAsyncPromise [
	<return: #TAsyncPromise>

	^ self
]

{ #category : #'api - promise' }
TAsyncPromise >> asyncThen: onFulfilledBlock [
	<return: #TAsyncPromise>

	^ self explicitRequirement
]

{ #category : #'api - promise' }
TAsyncPromise >> then: onFulfilledBlock [
	<return: #TAsyncPromise>

	^ self explicitRequirement
]

{ #category : #'api - promise' }
TAsyncPromise >> then: onFulfilledBlock otherwise: onRejectedBlock [
	<return: #TAsyncPromise>
	
	^ self explicitRequirement
]

{ #category : #'api - promise' }
TAsyncPromise >> wait [
	| aSemaphore anAwaitResult anAwaitError |
	
	aSemaphore := Semaphore new.
	
	self
		then: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ]
		otherwise: [ :anError |
			anAwaitError := anError freeze.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ AsyncFutureError signalForException: anAwaitError ].
	^ anAwaitResult
]
