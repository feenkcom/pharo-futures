Class {
	#name : #AsyncImageMethodsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#category : #'Futures-Extra'
}

{ #category : #comparing }
AsyncImageMethodsStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	^ self class = anObject class
]

{ #category : #comparing }
AsyncImageMethodsStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash
]

{ #category : #initialization }
AsyncImageMethodsStream >> initialize [
	super initialize.

	stream := (AsyncImageBehaviorsStream new collect: [ :eachBehavior | AsyncBehaviorAllMethodsStream forBehavior: eachBehavior ]) flatten
]

{ #category : #'api - stream copy' }
AsyncImageMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]
