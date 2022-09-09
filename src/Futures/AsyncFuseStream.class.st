"
#Fuse stream
Creates an utility stream that wraps another stream and allows users to query whether the underlying stream has finished or not.
If {{gtMethod:AsyncFuseStream>>#isDone}} method returns true, then all future calls to poll are guaranteed to return nothing. If this returns false, then the underlying stream is still in use.

##Example
{{gtExample:AsyncStreamExamples>>fuse}}
"
Class {
	#name : #AsyncFuseStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'done'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncFuseStream class >> forStream: anAsyncStream [
	^ self new
		stream: anAsyncStream
]

{ #category : #testing }
AsyncFuseStream >> isDone [
	^ done
]

{ #category : #'api - stream' }
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

{ #category : #'api - stream copy' }
AsyncFuseStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	done := false
]

{ #category : #'api - stream' }
AsyncFuseStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ done
		ifTrue: [ AsyncStreamSizeHint lowerBound: 0 higherBound: 0 ]
		ifFalse: [ stream sizeHint ]
]

{ #category : #'api - stream' }
AsyncFuseStream >> stop [
	"Stop the stream even if there are more items available"

	done := true
]

{ #category : #initialization }
AsyncFuseStream >> stream: anAsyncStream [
	stream := anAsyncStream.
	done := false
]
