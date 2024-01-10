Class {
	#name : #AsyncRepeatFutureStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'originalFuture',
		'currentFuture'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncRepeatFutureStream class >> forFuture: anAsyncFuture [
	^ self new future: anAsyncFuture
]

{ #category : #initialization }
AsyncRepeatFutureStream >> future: aFuture [
	originalFuture := aFuture
]

{ #category : #initialization }
AsyncRepeatFutureStream >> initialize [
	super initialize.
	
	currentFuture := AsyncOptionalValue none
]

{ #category : #'api - stream' }
AsyncRepeatFutureStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	currentFuture ifNone: [ currentFuture := AsyncOptionalValue some: originalFuture asyncSimilarCopy ]. 
	^ (currentFuture value poll: anAsynchronousContext)
		ifReady: [ :aReadyPoll |
			currentFuture := AsyncOptionalValue none.
			AsyncPoll ready: (AsyncOptionalValue some: aReadyPoll value) ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncRepeatFutureStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	originalFuture := originalFuture asyncSimilarCopy.
	currentFuture := AsyncOptionalValue none.
]

{ #category : #'api - stream' }
AsyncRepeatFutureStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ AsyncStreamSizeHint lowerBound: SmallInteger maxVal
]
