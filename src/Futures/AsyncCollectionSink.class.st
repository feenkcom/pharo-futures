"
#Collection Sink
Accumulates all items sent to it in a {{gtClass:OrderedCollection}}. It is possible though to initialize the sink with a custom collection.

##Examples
Collection sink with a default collection:
{{gtExample:AsyncSinkExamples>>#collectionSinkDefault}}

Collection sink with a set as a collection:
{{gtExample:AsyncSinkExamples>>#collectionSinkSet}}
"
Class {
	#name : #AsyncCollectionSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'collection'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'instance creation' }
AsyncCollectionSink class >> forCollection: aCollection [
	^ self new collection: aCollection
]

{ #category : #'api - sink' }
AsyncCollectionSink >> cleanSink [
	"Resets the sink to its original state"
	
	collection removeAll
]

{ #category : #'api - accessing' }
AsyncCollectionSink >> collection [
	^ collection
]

{ #category : #initialization }
AsyncCollectionSink >> collection: aCollection [
	collection := aCollection
]

{ #category : #initialization }
AsyncCollectionSink >> initialize [
	super initialize.

	collection := OrderedCollection new
]

{ #category : #'api - sink' }
AsyncCollectionSink >> pollClose: anAsynchronousContext [
	"Flush any remaining output and close this sink, if necessary.
	Returns Poll::Ready(true) when no buffered items remain and the sink has been successfully closed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via cx.waker().wake_by_ref()) to wake up when poll_close should be called again.
	If this function encounters an error, the sink should be considered to have failed permanently, and no more Sink methods should be called."
	<return: #AsyncPoll>
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
AsyncCollectionSink >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>

	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
AsyncCollectionSink >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
AsyncCollectionSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	collection add: anObject
]
