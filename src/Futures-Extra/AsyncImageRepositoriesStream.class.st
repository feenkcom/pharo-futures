Class {
	#name : #AsyncImageRepositoriesStream,
	#superclass : #AsyncAbstractWrappedStream,
	#category : #'Futures-Extra'
}

{ #category : #comparing }
AsyncImageRepositoriesStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	^ self class = anObject class
]

{ #category : #comparing }
AsyncImageRepositoriesStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash
]

{ #category : #initialization }
AsyncImageRepositoriesStream >> initialize [
	super initialize.
	
	stream := AsyncSequenceStream forCollection: [ IceRepository registry ] asAsyncFuture
]

{ #category : #'api - stream copy' }
AsyncImageRepositoriesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncImageRepositoriesStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
