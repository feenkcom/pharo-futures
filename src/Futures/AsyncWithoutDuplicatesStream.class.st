Class {
	#name : #AsyncWithoutDuplicatesStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'seenItems',
		'comparisonBlock',
		'setClass'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncWithoutDuplicatesStream class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'instance creation' }
AsyncWithoutDuplicatesStream class >> forStream: anAsyncStream basedOn: aBlock [
	^ self new stream: anAsyncStream; comparisonBlock: aBlock
]

{ #category : #accessing }
AsyncWithoutDuplicatesStream >> comparisonBlock: aBlock [
	comparisonBlock := aBlock
]

{ #category : #private }
AsyncWithoutDuplicatesStream >> convertSeenItems [
	seenItems ifNotNil: [ seenItems := setClass withAll: seenItems ]
]

{ #category : #'api - stream' }
AsyncWithoutDuplicatesStream >> pollNext: anAsynchronousContext [
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
					ifSome: [ :aValue |
						| compareValue |
						compareValue := comparisonBlock ifNil: [ aValue ] ifNotNil: [ comparisonBlock value: aValue ].
						(seenItems includes: compareValue)
							ifFalse: [
								seenItems add: compareValue.
								^ aReadyPoll ] ]
					ifNone: [
						seenItems := nil.
						^ aReadyPoll ] ]
			ifPending: [ :aPendingPoll | ^ aPendingPoll ]
	] repeat
]

{ #category : #'api - stream copy' }
AsyncWithoutDuplicatesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self stream: stream asyncSimilarCopy
]

{ #category : #initialization }
AsyncWithoutDuplicatesStream >> stream: anAsyncStream [
	stream := anAsyncStream.
	seenItems := (setClass ifNil: [ Set ]) new
]

{ #category : #accessing }
AsyncWithoutDuplicatesStream >> useContentComparison [
	setClass := GtStringContentSet.
	seenItems ifNotNil: [ seenItems := setClass withAll: seenItems ]
]

{ #category : #accessing }
AsyncWithoutDuplicatesStream >> useEqualityComparison [
	setClass := Set.
	seenItems ifNotNil: [ seenItems := setClass withAll: seenItems ]
]

{ #category : #accessing }
AsyncWithoutDuplicatesStream >> useIdentityComparison [
	setClass := IdentitySet.
	self convertSeenItems
]
