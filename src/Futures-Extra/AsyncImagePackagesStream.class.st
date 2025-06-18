Class {
	#name : #AsyncImagePackagesStream,
	#superclass : #AsyncAbstractWrappedStream,
	#category : #'Futures-Extra'
}

{ #category : #comparing }
AsyncImagePackagesStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	^ self class = anObject class
]

{ #category : #comparing }
AsyncImagePackagesStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash
]

{ #category : #initialization }
AsyncImagePackagesStream >> initialize [
	super initialize.
	
	stream := AsyncSequenceStream forCollection: [ self packageOrganizer packages ] asAsyncFuture
]

{ #category : #'api - stream copy' }
AsyncImagePackagesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncImagePackagesStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
