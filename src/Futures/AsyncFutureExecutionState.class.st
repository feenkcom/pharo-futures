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

{ #category : #testing }
AsyncFutureExecutionState >> isPending [
	^ false
]

{ #category : #testing }
AsyncFutureExecutionState >> isRunning [
	^ false
]

{ #category : #testing }
AsyncFutureExecutionState >> isSuccess [
	^ false
]
