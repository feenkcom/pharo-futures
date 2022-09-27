Class {
	#name : #AsyncFutureExecutionDefaultPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionDefaultPriority >> asPharoProcessPriority [
	^ 30
]

{ #category : #printing }
AsyncFutureExecutionDefaultPriority >> gtDisplayOn: aStream [
	aStream nextPutAll: 'Default'
]

{ #category : #accessing }
AsyncFutureExecutionDefaultPriority >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self asPharoProcessPriority asString;
		<< ')'
]
