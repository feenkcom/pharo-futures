Class {
	#name : 'AsyncFuseStream',
	#superclass : 'Object',
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'done'
	],
	#category : 'Futures-Streams'
}

{ #category : 'instance creation' }
AsyncFuseStream class >> stream: anAsyncStream amount: aNumber [
	^ self new
		stream: anAsyncStream
		amount: aNumber
]

{ #category : 'testing' }
AsyncFuseStream >> isDone [
	^ done
]

{ #category : 'api - stream' }
AsyncFuseStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	| aReadyPoll |
	
	self isDone
		ifTrue: [
			^ AsyncPoll ready: AsyncOptionalValue none ].
		
	aReadyPoll := (stream pollNext: anAsynchronousContext)
		ifPending: [ :aPendingPoll | ^ aPendingPoll ].
		
	aReadyPoll value isNone
		ifTrue: [ done := true ].
		
	^ aReadyPoll
]

{ #category : 'api - stream' }
AsyncFuseStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ done
		ifTrue: [ AsyncStreamSizeHint lowerBound: 0 higherBound: 0 ]
		ifFalse: [ stream sizeHint ]
]

{ #category : 'initialization' }
AsyncFuseStream >> stream: anAsyncStream [
	stream := anAsyncStream.
	done := false
]
