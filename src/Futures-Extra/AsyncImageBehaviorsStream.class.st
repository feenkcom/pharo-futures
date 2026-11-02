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
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again.
	The names come from a snapshot of the environment, so a class may have been removed after the snapshot was taken. Such a name is skipped by polling the inner stream again. Answering a pending poll for it would never be followed by a wake up, because the inner stream has already consumed the name, and the stream would never finish."

	<return: #AsyncPoll>
	[ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			aReadyPoll value
				ifSome: [ :aName | 
					self class environment
						at: aName
						ifPresent: [ :aBehavior | ^ AsyncPoll ready: (AsyncOptionalValue some: aBehavior) ]
						ifAbsent: [  "the class was removed after the snapshot, poll the next name" ] ]
				ifNone: [ ^ AsyncPoll ready: AsyncOptionalValue none ] ]
		ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] repeat
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
