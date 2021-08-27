"
#Filter stream
Filters the values produced by this stream according to the provided asynchronous predicate.
As values of this stream are made available, the provided predicate f will be run against them. If the predicate returns a {{gtClass:TAsyncFuture}} which resolves to {{gtClass:True}}, then the stream will yield the value, but if the predicate returns a {{gtClass:TAsyncFuture}} which resolves to {{gtClass:False}}, then the value will be discarded and the next value will be produced.

##Example

{{gtExample:AsyncStreamExamples>>#filter}}
"
Class {
	#name : 'AsyncFilterStream',
	#superclass : 'Object',
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'filter',
		'pendingItem',
		'pendingFilterFuture'
	],
	#category : 'Futures-Base - Streams'
}

{ #category : 'initialization' }
AsyncFilterStream class >> stream: anAsyncStream filter: aFilterBlock [
	^ self new stream: anAsyncStream filter: aFilterBlock
]

{ #category : 'initialization' }
AsyncFilterStream >> initialize [
	super initialize.
	
	pendingFilterFuture := AsyncOptionalValue none.
	pendingItem := AsyncOptionalValue none
]

{ #category : 'api - stream' }
AsyncFilterStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	[ 
		pendingFilterFuture
			ifSome: [ :aFuture |
				(aFuture poll: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						pendingFilterFuture := AsyncOptionalValue none.	
						aReadyPoll value
							ifTrue: [
								| anItem |
								anItem := pendingItem.
								pendingItem := AsyncOptionalValue none.
								^ AsyncPoll ready: anItem ].
						pendingItem := AsyncOptionalValue none.
					] 
					ifPending: [ :aPendingPoll | ^ aPendingPoll ]
			]
			ifNone: [
				(stream pollNext: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						aReadyPoll value
							ifSome: [ :aSomeValue |
								pendingFilterFuture := AsyncOptionalValue some: (filter value: aSomeValue) asFuture.
								pendingItem := AsyncOptionalValue some: aSomeValue ]
							ifNone: [ ^ AsyncPoll ready: AsyncOptionalValue none ] ]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] 
	] repeat.
]

{ #category : 'api - stream' }
AsyncFilterStream >> sizeHint [
	<return: #AsyncStreamSizeHint>
	| aPendingLength aStreamSizeHint aHigherBound |

	aPendingLength := pendingItem ifSome: [ 1 ] ifNone: [ 0 ].
	aStreamSizeHint := stream sizeHint.
	
	aHigherBound := aStreamSizeHint hasHigherBound
		ifTrue: [ aStreamSizeHint higherBound + aPendingLength ]
		ifFalse: [ nil ].

	^ AsyncStreamSizeHint lowerBound: 0 higherBound: aHigherBound
]

{ #category : 'initialization' }
AsyncFilterStream >> stream: anAsyncStream filter: aFilterBlock [
	stream := anAsyncStream.
	filter := aFilterBlock
]
