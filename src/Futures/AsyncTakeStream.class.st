"
#Take stream
Creates a new stream of at most n items of the underlying stream.
Once n items have been yielded from this stream then it will always return that the stream is done.

##Example
{{gtExample:AsyncStreamExamples>>take}}
"
Class {
	#name : #AsyncTakeStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'amount',
		'remaining'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncTakeStream class >> stream: anAsyncStream amount: aNumber [
	^ self new
		stream: anAsyncStream
		amount: aNumber
]

{ #category : #'api - stream' }
AsyncTakeStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ remaining isZero
		ifTrue: [ AsyncPoll ready: AsyncOptionalValue none ]
		ifFalse: [
			| nextItem |
			nextItem := (stream pollNext: anAsynchronousContext)
				ifReady: [ :aReadyPoll | aReadyPoll value ]
				ifPending: [ :aPendingPoll | ^ aPendingPoll ].

			nextItem
				ifSome: [ remaining := remaining - 1 ]
				ifNone: [ remaining := 0 ].

			AsyncPoll ready: nextItem ]
]

{ #category : #'api - stream copy' }
AsyncTakeStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	remaining := amount
]

{ #category : #'api - stream' }
AsyncTakeStream >> sizeHint [
	<return: #AsyncStreamSizeHint>
	| aStreamSizeHint aLowerBound aHigherBound |

	remaining isZero
		ifTrue: [ ^ AsyncStreamSizeHint lowerBound: 0 higherBound: 0 ].

	aStreamSizeHint := stream sizeHint.

	aLowerBound := aStreamSizeHint lowerBound min: remaining.
	aHigherBound := (aStreamSizeHint hasHigherBound and: [ aStreamSizeHint higherBound < remaining ])
		ifTrue: [ aStreamSizeHint higherBound ]
		ifFalse: [ remaining ].

	^ AsyncStreamSizeHint
		lowerBound: aLowerBound
		higherBound: aHigherBound
]

{ #category : #initialization }
AsyncTakeStream >> stream: anAsyncStream amount: aNumber [
	stream := anAsyncStream.
	amount := aNumber.
	remaining := amount
]
