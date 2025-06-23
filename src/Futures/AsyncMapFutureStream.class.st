Class {
	#name : #AsyncMapFutureStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'mapBlock',
		'pendingFuture'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncMapFutureStream class >> stream: anAsyncStream mapBlock: aBlock [
	^ self new stream: anAsyncStream mapBlock: aBlock
]

{ #category : #'api - stream' }
AsyncMapFutureStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	pendingFuture ifNotNil: [ :aFuture |
		| aPoll |
		
		aPoll := aFuture poll: anAsynchronousContext.
		aPoll isReady ifTrue: [ pendingFuture := nil ].

		^ aPoll map: [ :aValue | AsyncOptionalValue some: aValue ] ].

	^ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll |
			aReadyPoll value
				ifSome: [ :nextFuture |
					| aFuture aFuturePoll |	
						
					aFuture := (mapBlock value: nextFuture) asAsyncFuture.
					aFuturePoll := aFuture poll: anAsynchronousContext.
					aFuturePoll isPending
						ifTrue: [ pendingFuture := aFuture ].
					aFuturePoll map: [ :aValue | AsyncOptionalValue some: aValue ] ]
				ifNone: [ aReadyPoll ] ]
		
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncMapFutureStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #'api - stream' }
AsyncMapFutureStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]

{ #category : #'api - stream' }
AsyncMapFutureStream >> stream: anAsyncStream mapBlock: aBlock [
	stream := anAsyncStream.
	mapBlock := aBlock
]
