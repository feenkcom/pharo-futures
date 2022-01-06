Class {
	#name : #AsyncFutureExecutionDefaultPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionDefaultPriority >> asPharoProcessPriority [
	^ 30
]
