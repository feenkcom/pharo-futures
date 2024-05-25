Class {
	#name : #AsyncPaginationStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'initialValue',
		'currentFuture',
		'nextValueComputation',
		'futureComputation'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncPaginationStream class >> for: anObject future: aFutureComputation next: aNextComputation [
	^ self new
		initialValue: anObject
		futureComputation: aFutureComputation
		nextValueComputation: aNextComputation
]

{ #category : #initialization }
AsyncPaginationStream >> initialValue: anObject futureComputation: aFutureComputation nextValueComputation: aNextComputation [
	initialValue := anObject.
	futureComputation := aFutureComputation.
	nextValueComputation := aNextComputation.
	currentFuture := self privateFutureFor: initialValue
]

{ #category : #'api - stream' }
AsyncPaginationStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	currentFuture ifNil: [ ^ AsyncPoll ready: AsyncOptionalValue none ].

	^ (currentFuture poll: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			| polledValue nextValue |
			polledValue := aReadyPoll value.
			nextValue := nextValueComputation value: polledValue.
			nextValue
				ifNotNil: [ currentFuture := self privateFutureFor: nextValue ]
				ifNil: [ currentFuture := nil ].
			AsyncPoll ready: (AsyncOptionalValue some: polledValue) ]
]

{ #category : #'api - stream copy' }
AsyncPaginationStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	currentFuture := self privateFutureFor: initialValue
]

{ #category : #'api - stream' }
AsyncPaginationStream >> privateFutureFor: nextValue [
	^ (futureComputation value: nextValue) asAsyncFuture
]
