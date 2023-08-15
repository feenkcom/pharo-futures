"
#Weak stream
References the underlying stream weakly and closes when the original stream is garbage collected.
When working with infinite streams it is a good practice to wrap them in a weak stream to prevent memory leaks.
"
Class {
	#name : #AsyncWeakStream,
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
AsyncWeakStream class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #initialization }
AsyncWeakStream >> initialize [
	super initialize.
	
	waker := AsyncFutureExecutionAtomicWaker new
]

{ #category : #'api - stream' }
AsyncWeakStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	^ (stream at: 1)
		ifNil: [ AsyncPoll ready: AsyncOptionalValue none ]
		ifNotNil: [ :aStream |
			waker register: anAsynchronousContext waker.
			aStream pollNext: anAsynchronousContext ]
]

{ #category : #'api - stream copy' }
AsyncWeakStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	waker := AsyncFutureExecutionAtomicWaker new.
	stream := nil asWeakReference
]

{ #category : #initialization }
AsyncWeakStream >> stream: aStream [
	stream := aStream asWeakReference.

	self
		forPharo11OrNewer: [
			aStream finalizationRegistry
				add: aStream
				finalizer: (ObjectFinalizer new
					receiver: waker;
					selector: #wakeUp;
					arguments: #()) ]
		forPharo10: [
			aStream finalizationRegistry
				add: aStream
				executor: (ObjectFinalizer new
					receiver: waker;
					selector: #wakeUp;
					arguments: #()) ]
]
