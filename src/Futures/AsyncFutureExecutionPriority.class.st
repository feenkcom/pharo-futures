Class {
	#name : #AsyncFutureExecutionPriority,
	#superclass : #Object,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Executor'
}

{ #category : #cleanup }
AsyncFutureExecutionPriority class >> cleanUp [
	uniqueInstance := nil
]

{ #category : #accessing }
AsyncFutureExecutionPriority class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #comparing }
AsyncFutureExecutionPriority >> = anObject [
	^ self class = anObject class
]

{ #category : #converting }
AsyncFutureExecutionPriority >> asPharoProcessPriority [
	^ self explicitRequirement
]

{ #category : #comparing }
AsyncFutureExecutionPriority >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ 31 hash bitXor: self class hash
]
