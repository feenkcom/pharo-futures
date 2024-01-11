"
#Terminatable Stream
Creates a new Terminatable stream. When {{gtMethod:AsyncTerminatableStream>>#terminate}} is sent to the terminatable stream, the stream will complete immediately without making any further progress. Please note, that if the {{gtMethod:AsyncTerminatableStream>>#terminate}} is sent while the stream is being polled, that stream will finish the current polling step.
 
##Example
{{gtExample:AsyncStreamExamples>>#terminatable}} 

###Implementation details
Terminatable stream registers a waker to wake up the worker thread if the underlying stream returned a pending item.
"
Class {
	#name : #AsyncTerminatableStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'isTerminated',
		'waker'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncTerminatableStream class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #initialization }
AsyncTerminatableStream >> initialize [
	super initialize.
	
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : #'api - stream' }
AsyncTerminatableStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	isTerminated
		ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].

	waker register: anAsynchronousContext waker.

	^ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | aReadyPoll ]
		ifPending: [ :aPendingPoll |
			isTerminated
				ifTrue: [ AsyncPoll ready: AsyncOptionalValue none ]
				ifFalse: [ aPendingPoll ] ]
]

{ #category : #'api - stream copy' }
AsyncTerminatableStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	isTerminated := isTerminated copy.
	waker := AsyncFutureExecutionAtomicWaker new.
	stream := stream asyncSimilarCopy
]

{ #category : #initialization }
AsyncTerminatableStream >> stream: anAsyncStream [
	stream := anAsyncStream.
	isTerminated := false
]

{ #category : #'api - actions' }
AsyncTerminatableStream >> terminate [
	isTerminated := true.
	waker wakeUp
]
