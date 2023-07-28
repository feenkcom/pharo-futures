Class {
	#name : #AsyncBehaviorMethodStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior',
		'instanceStream',
		'classStream'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorMethodStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #comparing }
AsyncBehaviorMethodStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ behavior = anObject behavior
]

{ #category : #accessing }
AsyncBehaviorMethodStream >> behavior [

	^ behavior
]

{ #category : #accessing }
AsyncBehaviorMethodStream >> behavior: aBehavior [
	behavior := aBehavior.
	self initializeStreams.
	stream := {instanceStream.
			classStream} asAsyncStream flatten
]

{ #category : #comparing }
AsyncBehaviorMethodStream >> hash [
	"Answer an integer value that is related to the identity of the receiver."

	^ behavior hash
]

{ #category : #accessing }
AsyncBehaviorMethodStream >> initializeStreams [
	self subclassResponsibility
]

{ #category : #'api - stream copy' }
AsyncBehaviorMethodStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
