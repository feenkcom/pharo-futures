Class {
	#name : #AsyncFutureExecutionValueGroup,
	#superclass : #AsyncFutureExecutionGroup,
	#instVars : [
		'value'
	],
	#category : #'Futures-Executor'
}

{ #category : #comparing }
AsyncFutureExecutionValueGroup >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ value = anObject value
]

{ #category : #comparing }
AsyncFutureExecutionValueGroup >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ value hash
]

{ #category : #accessing }
AsyncFutureExecutionValueGroup >> label [
	^ value asString
]

{ #category : #accessing }
AsyncFutureExecutionValueGroup >> value [
	^ value
]

{ #category : #accessing }
AsyncFutureExecutionValueGroup >> value: anObject [

	value := anObject
]
