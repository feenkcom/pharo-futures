"
Similar to {{gtClass:AsyncOnceStream}} with a difference that it expects a {{gtClass:TAsyncFuture}} to resolve to {{gtClass:AsyncOptionalValue}} instead of the value directly. This allows the stream to be empty from the very beginning.
"
Class {
	#name : #AsyncMaybeOnceStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'future'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncMaybeOnceStream class >> forFuture: aFuture [
	^ self new future: aFuture
]

{ #category : #initialization }
AsyncMaybeOnceStream >> future: aFuture [
	future := AsyncOptionalValue some: aFuture
]

{ #category : #'api - stream' }
AsyncMaybeOnceStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	| aValue |

	aValue := future
		ifSome: [ :aFuture |
			(aFuture poll: anAsynchronousContext)
				ifReady: [ :aReadyPoll | aReadyPoll value ]
				ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
		ifNone: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
		
	future := AsyncOptionalValue none.
	^ AsyncPoll ready: aValue
]

{ #category : #'api - stream' }
AsyncMaybeOnceStream >> sizeHint [
	<return: #AsyncStreamSizeHint>
	| aSize |
	
	aSize := future
		ifSome: [ 1 ]
		ifNone: [ 0 ].
	
	^ AsyncStreamSizeHint
		lowerBound: 0
		higherBound: aSize
]
