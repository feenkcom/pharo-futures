"
#Chunks stream
An adaptor for chunking up items of the stream inside an {{gtClass:Array}}. This combinator will attempt to pull items from this stream and buffer them into a local buffer. At most `capacity` items will get buffered before they're yielded from the returned stream. Note that the arrays returned from this stream may not always have `capacity` elements. If the underlying stream ended and only a partial array was created, it'll be returned. Additionally if an error happens from the underlying stream then the currently buffered items will be yielded.

##Example
{{gtExample:AsyncStreamExamples>>#chunks}}
 
"
Class {
	#name : #AsyncChunksStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'capacity',
		'buffer'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncChunksStream class >> forStream: anAsyncStream capacity: aCapacity [
	^ self new stream: anAsyncStream capacity: aCapacity
]

{ #category : #'private - instance creation' }
AsyncChunksStream >> newBuffer [
	^ WriteStream on: (Array new: capacity)
]

{ #category : #'private - instance creation' }
AsyncChunksStream >> newEmptyBuffer [
	^ WriteStream on: (Array new: 0)
]

{ #category : #'api - stream' }
AsyncChunksStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	[ 
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :aNextItem |
						"Push the item into the buffer and check whether it is full.
						If so, replace our buffer with a new and empty one and return the full one."
						
						buffer nextPut: aNextItem.
						(buffer position >= capacity)
							ifTrue: [
								| theItems |
								
								theItems := buffer contents.
								buffer := self newBuffer.
								^ AsyncPoll ready: (AsyncOptionalValue some: theItems) ] ]
					ifNone: [
						"Since the underlying stream ran out of values, return what we have buffered, if we have anything."
						| aReturnValue |
						
						aReturnValue := buffer position isZero
							ifTrue: [ AsyncOptionalValue none ]
							ifFalse: [
								| theItems |
								theItems := buffer contents.
								buffer := self newEmptyBuffer.
								AsyncOptionalValue some: theItems ].
							
						^ AsyncPoll ready: aReturnValue ] ]
			ifPending: [ :aPendingPoll | ^ aPendingPoll ].
	] repeat
]

{ #category : #'api - stream copy' }
AsyncChunksStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	buffer := self newBuffer
]

{ #category : #initialize }
AsyncChunksStream >> stream: anAsyncStream capacity: aCapacity [
	self
		assert: [ aCapacity > 0 ]
		description: [ 'Capacity must be positive' ].

	stream := AsyncFuseStream forStream: anAsyncStream.
	capacity := aCapacity.
	buffer := self newBuffer
]
