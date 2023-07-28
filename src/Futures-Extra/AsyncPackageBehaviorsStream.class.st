Class {
	#name : #AsyncPackageBehaviorsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#instVars : [
		'package'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncPackageBehaviorsStream class >> forPackage: aPackage [
	^ self new forPackage: aPackage
]

{ #category : #'instance creation' }
AsyncPackageBehaviorsStream class >> forPackageNamed: aPackageName [
	^ self forPackage: aPackageName asPackage
]

{ #category : #'instance creation' }
AsyncPackageBehaviorsStream class >> package: aPackage [
	^ self forPackage: aPackage
]

{ #category : #comparing }
AsyncPackageBehaviorsStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ package = anObject package
]

{ #category : #initialization }
AsyncPackageBehaviorsStream >> forPackage: aRPackage [
	package := aRPackage.
	stream := AsyncSequenceStream forCollection: [ package definedClasses asArray ] asAsyncFuture.
]

{ #category : #comparing }
AsyncPackageBehaviorsStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ package hash
]

{ #category : #accessing }
AsyncPackageBehaviorsStream >> package [

	^ package
]

{ #category : #'api - stream copy' }
AsyncPackageBehaviorsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncPackageBehaviorsStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
