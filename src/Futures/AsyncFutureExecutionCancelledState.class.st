Class {
	#name : #AsyncFutureExecutionCancelledState,
	#superclass : #AsyncFutureExecutionState,
	#category : #'Futures-Executor'
}

{ #category : #testing }
AsyncFutureExecutionCancelledState >> isCancelled [
	^ true
]
