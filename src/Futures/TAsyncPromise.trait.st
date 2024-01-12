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

	"Compared to the #then: method, I guarantee that the onFulfilledBlock block 
	is executed asynchronously even if the original promise already has a value.
	
	It implies that onFulfilledBlock computation does not block a current process."

	<return: #TAsyncPromise>
	
	^ self explicitRequirement
]

{ #category : #testing }
TAsyncPromise >> isAsyncPromise [
	^ true
]

{ #category : #'accessing - utils' }
TAsyncPromise >> notifyPotentiallyIndefinitelyPending [
	"Is sent by the futures worker when promise switches to the indefinitely pending state.
	Only promises that are derived from futures can be inidefinitely pending"
]

{ #category : #'accessing - utils' }
TAsyncPromise >> relatedFutures [
	^ #()
]

{ #category : #'api - promise' }
TAsyncPromise >> then: onFulfilledBlock [

	"If the original promise already has a computed value, the onFulfilledBlock block 
	is computed in a current process. If the promise does not have the value,
	the onFulfilledBlock block is computed later in another process.
	
	Notice that onFulfilledBlock is computed only on success promise values. 
	If you need handle also failures (rejected values), consider using #then:otherwise:.
	
	If you want to guarantee that the current process is never blocked (e.g., 
	due to an expensive onFulfilledBlock computation), consider using #asyncThen:"

	<return: #TAsyncPromise>

	^ self explicitRequirement
]

{ #category : #'api - promise' }
TAsyncPromise >> then: onFulfilledBlock otherwise: onRejectedBlock [

	"Compared to the #then: method, I handle an otherwise (error) case too.
	Consider to return a 'sensible' onRejectedBlock value, which is usually 
	of the same type as the onFulfilledBlock return value. For example:
	
	[ 1 / 0 ] asAsyncPromise then: [ :n | n * 2 ] otherwise: [ :e | 0 ]"

	<return: #TAsyncPromise>
	
	^ self explicitRequirement
]

{ #category : #'api - promise' }
TAsyncPromise >> wait [
	| aSemaphore anAwaitResult anAwaitError |
	
	aSemaphore := Semaphore new.
	anAwaitResult := anAwaitError := nil.
	
	self
		then: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ]
		otherwise: [ :anError |
			anAwaitError := anError freeze.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ ^ anAwaitError ].
	^ anAwaitResult
]

{ #category : #'api - promise' }
TAsyncPromise >> whenIndefinitelyPending: aBlock [
	^ self
]
