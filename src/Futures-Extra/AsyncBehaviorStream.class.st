Class {
	#name : #AsyncBehaviorStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #comparing }
AsyncBehaviorStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ behavior = anObject behavior
]

{ #category : #accessing }
AsyncBehaviorStream >> behavior [

	^ behavior
]

{ #category : #initialization }
AsyncBehaviorStream >> behavior: aBehavior [
	behavior := aBehavior.
	self initializeStream
]

{ #category : #comparing }
AsyncBehaviorStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ behavior hash
]

{ #category : #initialization }
AsyncBehaviorStream >> initializeStream [
	self subclassResponsibility
]

{ #category : #'api - stream copy' }
AsyncBehaviorStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
