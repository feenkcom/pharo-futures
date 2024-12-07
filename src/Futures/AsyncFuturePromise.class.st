Class {
	#name : #AsyncFuturePromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'future',
		'group',
		'priority',
		'errorHandler',
		'worker',
		'executionState',
		'maxAmountOfWorkers'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'api - promise' }
AsyncFuturePromise >> cancel: anAsyncFutureExecutionCancellation [
	"Cancel the future according to the given cancellation strategy"
	| aWorker |

	self critical: [
		"Is already cancelled"
		executionState isCancelled
			ifTrue: [ ^ self ].

		"can not cancel a successful promise"
		executionState isSuccess
			ifTrue: [ ^ self ].

		executionState := AsyncFutureExecutionCancelledState uniqueInstance.
		worker
			"Worker is not assigned yet, meaning that the future is not yet scheduled"
			ifNil: [ ^ self ].

		aWorker := worker.

		anAsyncFutureExecutionCancellation
			cancel: self
			worker: aWorker ]
]

{ #category : #'api - promise' }
AsyncFuturePromise >> cancelHard [
	self cancel: AsyncFutureExecutionHardCancellation uniqueInstance
]

{ #category : #'api - promise' }
AsyncFuturePromise >> cancelSoft [
	self cancel: AsyncFutureExecutionSoftCancellation uniqueInstance
]

{ #category : #'api - promise' }
AsyncFuturePromise >> critical: aBlock [
	^ mutex critical: aBlock
]

{ #category : #accessing }
AsyncFuturePromise >> errorHandler [

	^ errorHandler
]

{ #category : #accessing }
AsyncFuturePromise >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #'private - state' }
AsyncFuturePromise >> fulfillWithValue: aValue [
	self critical: [
		"The future is already fulfilled or rejected"
		executionState isSuccess
			ifTrue: [ ^ self ].

		executionState := AsyncFutureExecutionSuccessfulState uniqueInstance ].
	
	worker := nil.
	self fulfillWithTransformedValue: aValue
]

{ #category : #accessing }
AsyncFuturePromise >> future [

	^ future
]

{ #category : #accessing }
AsyncFuturePromise >> future: anObject [

	future := anObject
]

{ #category : #accessing }
AsyncFuturePromise >> group [

	^ group
]

{ #category : #accessing }
AsyncFuturePromise >> group: anObject [

	group := anObject
]

{ #category : #initialization }
AsyncFuturePromise >> initialize [
	super initialize.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.
	executionState := AsyncFutureExecutionPendingState uniqueInstance.
	errorHandler := AsyncNoneErrorHandler uniqueInstance.
	maxAmountOfWorkers := 1
]

{ #category : #'api - promise' }
AsyncFuturePromise >> isCancelled [
	^ self critical: [ executionState isCancelled ]
]

{ #category : #accessing }
AsyncFuturePromise >> maxAmountOfWorkers [
	^ maxAmountOfWorkers
]

{ #category : #accessing }
AsyncFuturePromise >> maxAmountOfWorkers: anObject [
	maxAmountOfWorkers := anObject
]

{ #category : #printing }
AsyncFuturePromise >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Pending future promise';
		nextPutAll: ' state: ';
		print: state.
	aStream
		nextPutAll: ' group: ';
		nextPutAll: (group ifNotNil: #label).
	aStream
		nextPutAll: ' future: ';
		print: future
]

{ #category : #accessing }
AsyncFuturePromise >> priority [
	<return: #AsyncFutureExecutionPriority>

	^ priority
]

{ #category : #accessing }
AsyncFuturePromise >> priority: anAsyncFutureExecutionPriority [
	priority := anAsyncFutureExecutionPriority
]

{ #category : #'private - state' }
AsyncFuturePromise >> rejectWithCancellation [
	self rejectWithError: AsyncFutureCancelled new
]

{ #category : #'private - state' }
AsyncFuturePromise >> rejectWithError: anError [
	self critical: [
		"The future is already fulfilled or rejected"
		executionState isSuccess
			ifTrue: [ ^ self ].

		executionState := AsyncFutureExecutionSuccessfulState uniqueInstance ].

	worker := nil.
	errorHandler handleError: anError.
	self rejectWithTransformedError: anError
]

{ #category : #accessing }
AsyncFuturePromise >> relatedFutures [
	^ { future }
]

{ #category : #accessing }
AsyncFuturePromise >> worker [

	^ worker
]

{ #category : #accessing }
AsyncFuturePromise >> worker: aWorker [
	"Assign a worker when the futures is scheduled"

	self critical: [ worker := aWorker ]
]
