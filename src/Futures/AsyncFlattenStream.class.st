"
#Flatten stream
Flattens a stream of streams into just one continuous stream.

##Example
{{gtExample:AsyncStreamExamples>>#flatten}}
"
Class {
	#name : #AsyncFlattenStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'next'
	],
	#category : 'Futures-Base - Streams'
}

{ #category : #accessing }
AsyncFlattenStream class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #initialization }
AsyncFlattenStream >> initialize [
	super initialize.
	
	next := AsyncOptionalValue none
]

{ #category : #'api - stream' }
AsyncFlattenStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	[ 
		next
			ifSome: [ :aNextStream |
				(aNextStream pollNext: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						aReadyPoll value isSome
							ifTrue: [ ^ AsyncPoll ready: aReadyPoll value ]
							ifFalse: [ next := AsyncOptionalValue none ].
					]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ]
			]
			ifNone: [
				(stream pollNext: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						aReadyPoll value isSome
							ifTrue: [ next := aReadyPoll value ]
							ifFalse: [ ^ AsyncPoll ready: AsyncOptionalValue none ] ]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
		] repeat
]

{ #category : #accessing }
AsyncFlattenStream >> stream: anAsyncStream [
	stream := anAsyncStream
]
