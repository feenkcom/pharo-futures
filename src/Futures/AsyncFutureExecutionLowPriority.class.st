Class {
	#name : #AsyncFutureExecutionLowPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionLowPriority >> asPharoProcessPriority [
	^ 25
]
