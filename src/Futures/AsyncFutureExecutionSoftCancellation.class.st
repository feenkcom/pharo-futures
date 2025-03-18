Class {
	#name : #AsyncFutureExecutionSoftCancellation,
	#superclass : #AsyncFutureExecutionCancellation,
	#category : #'Futures-Executor'
}

{ #category : #'api - termination' }
AsyncFutureExecutionSoftCancellation >> cancel: anAsyncPendingFuturePromise worker: aWorker [
	(aWorker unschedule: anAsyncPendingFuturePromise)
		ifTrue: [ anAsyncPendingFuturePromise rejectWithCancellation ]
]
