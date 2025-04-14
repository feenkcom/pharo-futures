Class {
	#name : #AsyncFutureExecutionUserBackgroundPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionUserBackgroundPriority >> asPharoProcessPriority [
	^ 23
]

{ #category : #printing }
AsyncFutureExecutionUserBackgroundPriority >> gtDisplayOn: aStream [
	aStream nextPutAll: 'User Background'
]
