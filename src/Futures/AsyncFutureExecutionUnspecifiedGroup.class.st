Class {
	#name : #AsyncFutureExecutionUnspecifiedGroup,
	#superclass : #AsyncFutureExecutionGroup,
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionUnspecifiedGroup class >> cleanUp [
	uniqueInstance := nil
]

{ #category : #accessing }
AsyncFutureExecutionUnspecifiedGroup class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #comparing }
AsyncFutureExecutionUnspecifiedGroup >> = anObject [
	^ self class = anObject class
]

{ #category : #comparing }
AsyncFutureExecutionUnspecifiedGroup >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ 31 hash bitXor: self class hash
]

{ #category : #testing }
AsyncFutureExecutionUnspecifiedGroup >> isUnspecified [
	^ true
]

{ #category : #accessing }
AsyncFutureExecutionUnspecifiedGroup >> label [
	^ 'Unspecified'
]
