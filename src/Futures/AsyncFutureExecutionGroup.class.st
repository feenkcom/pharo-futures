Class {
	#name : #AsyncFutureExecutionGroup,
	#superclass : #Object,
	#category : #'Futures-Executor'
}

{ #category : #testing }
AsyncFutureExecutionGroup >> isUnspecified [
	^ false
]

{ #category : #accessing }
AsyncFutureExecutionGroup >> label [
	^ self subclassResponsibility
]
