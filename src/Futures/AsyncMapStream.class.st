"
#Map stream
Maps this stream's items to a different type, returning a new stream of the resulting type.
The provided closure is executed over all elements of this stream as they are made available. It is executed inline with calls to {{gtMethod:TAsyncStream>>#pollNext:}}.

##Example
{{gtExample:AsyncStreamExamples>>#map}}
"
Class {
	#name : #AsyncMapStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'mapBlock'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncMapStream class >> stream: anAsyncStream mapBlock: aBlock [
	^ self new stream: anAsyncStream mapBlock: aBlock
]

{ #category : #'api - stream' }
AsyncMapStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | AsyncPoll ready: (aReadyPoll value map: mapBlock) ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncMapStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream similarCopy
]

{ #category : #'api - stream' }
AsyncMapStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ stream sizeHint
]

{ #category : #'api - stream' }
AsyncMapStream >> stream: anAsyncStream mapBlock: aBlock [
	stream := anAsyncStream.
	mapBlock := aBlock
]
