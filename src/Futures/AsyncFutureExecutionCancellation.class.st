Class {
	#name : #AsyncFutureExecutionCancellation,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionCancellation class >> cleanUp [
	uniqueInstance := nil
]

{ #category : #accessing }
AsyncFutureExecutionCancellation class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #'api - termination' }
AsyncFutureExecutionCancellation >> cancel: anAsyncPendingFuturePromise worker: aWorker [
	self subclassResponsibility
]
