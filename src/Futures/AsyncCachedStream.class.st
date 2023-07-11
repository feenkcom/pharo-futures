"
#Cached stream
Caches items across all {{gtMethod:TAsyncStream>>#asyncSimilarCopy}}. Correctly handles the case when each similar stream is polled from a difference worker process, the cache is shared and synchronised between such streams.

##Example

{{gtExample:AsyncStreamExamples>>#cachedStream}}
"
Class {
	#name : #AsyncCachedStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'collector',
		'index'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncCachedStream class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #accessing }
AsyncCachedStream >> contents [
	"Convenience method, for when we really just want the collection and not a future."

	| collection |
	collection := OrderedCollection new.
	(self asyncSimilarCopy do: [ :each | collection add: each ]) await.
	^ collection
]

{ #category : #accessing }
AsyncCachedStream >> items [
	^ self contents
]

{ #category : #'api - stream' }
AsyncCachedStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	^ (collector
		pollAt: index
		context: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ index := index + 1 ].
				aReadyPoll ]
			ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncCachedStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	index := 1
]

{ #category : #initialization }
AsyncCachedStream >> stream: anAsyncStream [
	collector := AsyncStreamCache forStream: anAsyncStream.
	index := 1
]
