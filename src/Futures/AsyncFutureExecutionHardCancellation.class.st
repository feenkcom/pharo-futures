Class {
	#name : #AsyncFutureExecutionHardCancellation,
	#superclass : #AsyncFutureExecutionCancellation,
	#category : #'Futures-Executor'
}

{ #category : #'api - termination' }
AsyncFutureExecutionHardCancellation >> cancel: anAsyncPendingFuturePromise worker: aWorker [
	aWorker terminate: anAsyncPendingFuturePromise
]
