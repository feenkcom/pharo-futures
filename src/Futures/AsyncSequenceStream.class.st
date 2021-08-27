"
#Sequenceable Collection Stream
Creates a stream that wraps a {{gtClass:SequenceableCollection}} or a {{gtClass:TAsyncFuture}} that returns said collection.

##Example
{{gtExample:AsyncStreamExamples>>sequence}}
"
Class {
	#name : 'AsyncSequenceStream',
	#superclass : 'Object',
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'collectionFuture',
		'collection',
		'index',
		'done'
	],
	#category : 'Futures-Base - Streams'
}

{ #category : 'initialization' }
AsyncSequenceStream class >> forCollection: aCollectionOrFuture [
	^ self new collection: aCollectionOrFuture
]

{ #category : 'initialization' }
AsyncSequenceStream >> collection: aCollectionOrFuture [
	collectionFuture := aCollectionOrFuture asFuture.
]

{ #category : 'initialization' }
AsyncSequenceStream >> initialize [
	super initialize.
	
	index := 1.
	done := false
]

{ #category : 'api - stream' }
AsyncSequenceStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	[
		done ifTrue: [
			^ AsyncPoll ready: AsyncOptionalValue none ].

		collection
			ifNotNil: [ :aCollection |
				index <= aCollection size
					ifTrue: [
						| aNextItem |

						aNextItem := aCollection at: index.
						index := index + 1.

						index > aCollection size
							ifTrue: [
								done := true.
								collection := nil ].
						
						^ AsyncPoll ready: (AsyncOptionalValue some: aNextItem) ]
					ifFalse: [
						done := true.
						collection := nil.
						^ AsyncPoll ready: AsyncOptionalValue none ] ]
		ifNil: [ 
			(collectionFuture poll: anAsynchronousContext)
				ifReady: [ :aReadyPoll |
					collection := aReadyPoll value.
					index := 1 ]
				ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
	] repeat.
]

{ #category : 'api - stream' }
AsyncSequenceStream >> sizeHint [
	<return: #AsyncStreamSizeHint>
	| remainingSize |
	
	remainingSize := collection
		ifNil: [ 0 ]
		ifNotNil: [ :aCollection | aCollection size - index + 1 ].

	^ AsyncStreamSizeHint
		lowerBound: remainingSize
]
