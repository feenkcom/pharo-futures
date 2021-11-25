"
#With timeout stream
Creates a new stream that will timeout after a certain period, not producing any more results.
Note that this stream will take longer to terminate, based on item creation time. If an underlying stream takes 5 seconds to produce an item, for instance, and only 2 seconds are left until termination time, the full 5 seconds will be taken, the item will be produced, and *then* the stream will terminate.

##Example
{{gtExample:AsyncStreamExamples>>timeout}}
"
Class {
	#name : #AsyncWithTimeoutStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'startedTime',
		'duration',
		'stream'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncWithTimeoutStream class >> stream: anAsynchronousStream for: aDuration [
	^ self new stream: anAsynchronousStream for: aDuration
]

{ #category : #'api - stream' }
AsyncWithTimeoutStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated or the timeout has been reached, and poll_next should not be invoked again."
	| elapsedTime | 
	
	elapsedTime := startedTime
		ifNil: [
			startedTime := DateAndTime now.
			0 milliSecond ]
		ifNotNil: [ :aDateAndTime | DateAndTime now - aDateAndTime ].

	^ elapsedTime > duration
		ifTrue: [ AsyncPoll ready: AsyncOptionalValue none ]
		ifFalse: [ stream pollNext: anAsynchronousContext ]
]

{ #category : #'api - stream copy' }
AsyncWithTimeoutStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	startedTime := nil
]

{ #category : #initialization }
AsyncWithTimeoutStream >> stream: anAsynchronousStream for: aDuration [
	stream := anAsynchronousStream.
	duration := aDuration.
	startedTime := nil
]
