"
#Indexed map Stream
Similar to {{gtClass:AsyncMapStream}} but also passes an index of an item to the map block.

##Example
{{gtExample:AsyncStreamExamples>>#mapIndexed}}
"
Class {
	#name : #AsyncMapWithIndexStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'mapBlock',
		'index'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncMapWithIndexStream class >> forStream: anAsyncStream map: aBlock [
	^ self new
		stream: anAsyncStream
		map: aBlock
]

{ #category : #'api - stream' }
AsyncMapWithIndexStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	index := index + 1.
	
	^ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll |
			aReadyPoll value
				ifSome: [ :anItem |
					| aMappedValue |
					aMappedValue := mapBlock value: anItem value: index.
					AsyncPoll ready: (AsyncOptionalValue some: aMappedValue)  ]
				ifNone: [ aReadyPoll ] ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncMapWithIndexStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	index := 0
]

{ #category : #initialization }
AsyncMapWithIndexStream >> stream: anAsyncStream map: aBlock [
	stream := anAsyncStream.
	mapBlock := aBlock.
	index := 0
]
