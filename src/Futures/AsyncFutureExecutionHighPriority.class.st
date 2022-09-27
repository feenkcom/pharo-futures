Class {
	#name : #AsyncFutureExecutionHighPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionHighPriority >> asPharoProcessPriority [
	^ 35
]

{ #category : #printing }
AsyncFutureExecutionHighPriority >> gtDisplayOn: aStream [
	aStream nextPutAll: 'High'
]
