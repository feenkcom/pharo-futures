Class {
	#name : #AsyncBehaviorInstanceTraitedMethodsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'behavior'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorInstanceTraitedMethodsStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #comparing }
AsyncBehaviorInstanceTraitedMethodsStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ behavior = anObject behavior
]

{ #category : #accessing }
AsyncBehaviorInstanceTraitedMethodsStream >> behavior [

	^ behavior
]

{ #category : #initialization }
AsyncBehaviorInstanceTraitedMethodsStream >> behavior: aBehavior [
	behavior := aBehavior.
	stream := AsyncSequenceStream forCollection: [ behavior methods ] asAsyncFuture
]

{ #category : #comparing }
AsyncBehaviorInstanceTraitedMethodsStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ behavior hash
]

{ #category : #'api - stream copy' }
AsyncBehaviorInstanceTraitedMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
