Class {
	#name : #AsyncRepositoryBehaviorsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'repository'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncRepositoryBehaviorsStream class >> forRepository: anIceRepository [

	^ self new forRepository: anIceRepository
]

{ #category : #comparing }
AsyncRepositoryBehaviorsStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ repository = anObject package
]

{ #category : #initialization }
AsyncRepositoryBehaviorsStream >> forRepository: anIceRepository [
	repository := anIceRepository.
	stream := AsyncSequenceStream forCollection: [ repository loadedPackages flatCollect: [ :icePackage | icePackage package asPackage definedClasses ] as: Array ] asAsyncFuture.
]

{ #category : #comparing }
AsyncRepositoryBehaviorsStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ repository hash
]

{ #category : #'api - stream copy' }
AsyncRepositoryBehaviorsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncRepositoryBehaviorsStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
