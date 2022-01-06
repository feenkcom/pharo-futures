Class {
	#name : #AsyncFutureExecutionHighPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionHighPriority >> asPharoProcessPriority [
	^ 35
]
