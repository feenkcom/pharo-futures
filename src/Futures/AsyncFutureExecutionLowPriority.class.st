Class {
	#name : #AsyncFutureExecutionLowPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionLowPriority >> asPharoProcessPriority [
	^ 25
]

{ #category : #printing }
AsyncFutureExecutionLowPriority >> gtDisplayOn: aStream [
	aStream nextPutAll: 'Low'
]
