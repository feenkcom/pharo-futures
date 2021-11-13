Class {
	#name : #AsyncImageBehaviorsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Extra'
}

{ #category : #initialization }
AsyncImageBehaviorsStream >> initialize [
	super initialize.

	stream := AsyncSequenceStream forCollection: [ self class environment classNames copy ] asAsyncFuture
]

{ #category : #'api - stream' }
AsyncImageBehaviorsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ (stream pollNext: anAsynchronousContext)
		map: [ :aNameOption |
			aNameOption map: [ :aName |
				self class environment
					at: aName
					ifPresent: [ :aBehavior | aBehavior ]
					ifAbsent: [ ^ AsyncPoll pending ] ] ]
]

{ #category : #'api - stream copy' }
AsyncImageBehaviorsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream similarCopy
]

{ #category : #'api - stream' }
AsyncImageBehaviorsStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
