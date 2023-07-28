Class {
	#name : #AsyncImageBehaviorsStream,
	#superclass : #AsyncAbstractWrappedStream,
	#category : #'Futures-Extra'
}

{ #category : #comparing }
AsyncImageBehaviorsStream >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	^ self class = anObject class
]

{ #category : #comparing }
AsyncImageBehaviorsStream >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ self class hash
]

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
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncImageBehaviorsStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]
