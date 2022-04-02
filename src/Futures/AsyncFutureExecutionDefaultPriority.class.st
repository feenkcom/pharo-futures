Class {
	#name : #AsyncFutureExecutionDefaultPriority,
	#superclass : #AsyncFutureExecutionPriority,
	#category : #'Futures-Executor'
}

{ #category : #converting }
AsyncFutureExecutionDefaultPriority >> asPharoProcessPriority [
	^ 30
]

{ #category : #accessing }
AsyncFutureExecutionDefaultPriority >> printOn: aStream [
	super printOn: aStream.
	aStream
		<< '(';
		<< self asPharoProcessPriority asString;
		<< ')'
]
