Class {
	#name : #AsyncFutureExecutionImportantPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionImportantPriority >> asPharoProcessPriority [
	^ 36
]

{ #category : #printing }
AsyncFutureExecutionImportantPriority >> gtDisplayOn: aStream [
	aStream nextPutAll: 'Important'
]
