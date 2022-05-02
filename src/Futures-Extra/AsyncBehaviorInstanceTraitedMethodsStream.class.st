Class {
	#name : #AsyncBehaviorInstanceTraitedMethodsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'behavior',
		'stream'
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

{ #category : #'api - stream' }
AsyncBehaviorInstanceTraitedMethodsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	stream ifNil: [
		^ AsyncPoll ready: AsyncOptionalValue none ].
	
	^ stream pollNext: anAsynchronousContext
]

{ #category : #'api - stream copy' }
AsyncBehaviorInstanceTraitedMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self behavior: behavior
]
