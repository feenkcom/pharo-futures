Class {
	#name : #AsyncFutureExecutionRunningState,
	#superclass : #AsyncFutureExecutionState,
	#category : #'Futures-Executor'
}

{ #category : #testing }
AsyncFutureExecutionRunningState >> isPending [
	^ true
]

{ #category : #testing }
AsyncFutureExecutionRunningState >> isRunning [
	^ true
]
