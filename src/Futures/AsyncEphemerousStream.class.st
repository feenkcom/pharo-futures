Class {
	#name : #AsyncEphemerousStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'waker'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncEphemerousStream class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #initialization }
AsyncEphemerousStream >> initialize [
	super initialize.
	
	waker := AsyncFutureExecutionAtomicWaker new.
	stream := AsyncMutex for: nil
]

{ #category : #mourning }
AsyncEphemerousStream >> mourn [
	NonInteractiveTranscript stdout
		nextPutAll: 'Stream: mourn';
		cr.
	stream value: nil.
	waker wakeUp
]

{ #category : #'api - stream' }
AsyncEphemerousStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ stream lock: [ :aStream |
			aStream
				ifNil: [
					waker unregister.
					AsyncPoll ready: AsyncOptionalValue none ]
				ifNotNil: [
					waker register: anAsynchronousContext waker.
					aStream pollNext: anAsynchronousContext ] ]
]

{ #category : #'api - stream copy' }
AsyncEphemerousStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	waker := AsyncFutureExecutionAtomicWaker new.
	stream := nil
]

{ #category : #initialization }
AsyncEphemerousStream >> stream: aStream [
	stream value: aStream
]
