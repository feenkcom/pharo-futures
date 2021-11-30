Class {
	#name : #AsyncFileStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'file',
		'stream'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncFileStream class >> forFile: aFileReference [
	^ self new file: aFileReference
]

{ #category : #initialization }
AsyncFileStream >> file: aFileReference [
	file := aFileReference.
	stream := file readStream.
]

{ #category : #accessing }
AsyncFileStream >> pollNext: anAsynchronousContext [

	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."

	<return: #AsyncPoll>
	stream closed ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
	stream atEnd ifTrue: [ 
		stream close.
		^ AsyncPoll ready: AsyncOptionalValue none ].

	^ AsyncPoll ready: (AsyncOptionalValue some: stream next)
]

{ #category : #accessing }
AsyncFileStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"

	stream closed ifFalse: [ stream close ].
	stream := file readStream.
]
