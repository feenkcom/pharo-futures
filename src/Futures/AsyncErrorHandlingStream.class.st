Class {
	#name : #AsyncErrorHandlingStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'hadError',
		'errorBlock',
		'errorClass'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncErrorHandlingStream class >> stream: anAsyncStream on: anException do: aHandlerAction [
	^ self new
		stream: anAsyncStream
		on: anException
		do: aHandlerAction
]

{ #category : #'api - stream' }
AsyncErrorHandlingStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	hadError
		ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].

	^ [ stream pollNext: anAsynchronousContext ]
		on: errorClass
		do: [ :anError |
			hadError := true.
			AsyncPoll ready: (AsyncOptionalValue some: (errorBlock value: anError)) ]
]

{ #category : #'api - stream copy' }
AsyncErrorHandlingStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	hadError := false
]

{ #category : #initialization }
AsyncErrorHandlingStream >> stream: anAsyncStream on: anException do: aHandlerAction [
	stream := anAsyncStream.
	errorClass := anException.
	errorBlock := aHandlerAction.
	hadError := false
]
