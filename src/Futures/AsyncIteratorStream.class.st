Class {
	#name : #AsyncIteratorStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'iterator'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncIteratorStream class >> forIterator: anIterator [
	^ self new iterator: anIterator
]

{ #category : #accessing }
AsyncIteratorStream >> iterator: anIterator [
	iterator := anIterator
]

{ #category : #'api - stream' }
AsyncIteratorStream >> pollNext: anAsynchronousContext [

	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	^ iterator hasNext
		  ifTrue: [ 
		  AsyncPoll ready: (AsyncOptionalValue some: iterator next) ]
		  ifFalse: [ AsyncPoll ready: AsyncOptionalValue none ]
]
