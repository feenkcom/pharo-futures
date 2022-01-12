Class {
	#name : #AsyncFutureExecutionState,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionState class >> cleanUp [
	uniqueInstance := nil
]

{ #category : #accessing }
AsyncFutureExecutionState class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #testing }
AsyncFutureExecutionState >> isCancelled [
	^ false
]
