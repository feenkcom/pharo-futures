Class {
	#name : #AsyncPendingFuturePromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'future',
		'group',
		'priority',
		'errorHandler',
		'worker',
		'executionState'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'api - promise' }
AsyncPendingFuturePromise >> cancel: anAsyncFutureExecutionCancellation [
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
AsyncPendingFuturePromise >> cancelHard [
	self cancel: AsyncFutureExecutionHardCancellation uniqueInstance
]

{ #category : #'api - promise' }
AsyncPendingFuturePromise >> cancelSoft [
	self cancel: AsyncFutureExecutionSoftCancellation uniqueInstance
]

{ #category : #'api - promise' }
AsyncPendingFuturePromise >> critical: aBlock [
	^ mutex critical: aBlock
]

{ #category : #accessing }
AsyncPendingFuturePromise >> errorHandler [

	^ errorHandler
]

{ #category : #accessing }
AsyncPendingFuturePromise >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #'private - state' }
AsyncPendingFuturePromise >> fulfillWithValue: aValue [
	self critical: [
		"The future is already fulfilled or rejected"
		executionState isSuccess
			ifTrue: [ ^ self ].

		executionState := AsyncFutureExecutionSuccessfulState uniqueInstance ].
	
	worker := nil.
	self fulfillWithTransformedValue: aValue
]

{ #category : #accessing }
AsyncPendingFuturePromise >> future [

	^ future
]

{ #category : #accessing }
AsyncPendingFuturePromise >> future: anObject [

	future := anObject
]

{ #category : #accessing }
AsyncPendingFuturePromise >> group [

	^ group
]

{ #category : #accessing }
AsyncPendingFuturePromise >> group: anObject [

	group := anObject
]

{ #category : #initialization }
AsyncPendingFuturePromise >> initialize [
	super initialize.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.
	executionState := AsyncFutureExecutionPendingState uniqueInstance.
	errorHandler := AsyncNoneErrorHandler uniqueInstance.
]

{ #category : #'api - promise' }
AsyncPendingFuturePromise >> isCancelled [
	^ self critical: [ executionState isCancelled ]
]

{ #category : #printing }
AsyncPendingFuturePromise >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Pending future promise';
		nextPutAll: ' state: ';
		print: state.
	aStream
		nextPutAll: ' future: ';
		print: future
]

{ #category : #accessing }
AsyncPendingFuturePromise >> priority [
	<return: #AsyncFutureExecutionPriority>

	^ priority
]

{ #category : #accessing }
AsyncPendingFuturePromise >> priority: anAsyncFutureExecutionPriority [
	priority := anAsyncFutureExecutionPriority
]

{ #category : #'private - state' }
AsyncPendingFuturePromise >> rejectWithCancellation [
	self rejectWithError: AsyncFutureCancelled new
]

{ #category : #'private - state' }
AsyncPendingFuturePromise >> rejectWithError: anError [
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
AsyncPendingFuturePromise >> relatedFutures [
	^ { future }
]

{ #category : #accessing }
AsyncPendingFuturePromise >> worker [

	^ worker
]

{ #category : #accessing }
AsyncPendingFuturePromise >> worker: aWorker [
	"Assign a worker when the futures is scheduled"

	self critical: [ worker := aWorker ]
]
