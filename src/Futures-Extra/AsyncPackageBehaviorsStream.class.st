Class {
	#name : #AsyncPackageBehaviorsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'package',
		'stream'
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

{ #category : #'api - stream' }
AsyncPackageBehaviorsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ stream pollNext: anAsynchronousContext
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