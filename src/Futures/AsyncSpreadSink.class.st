Class {
	#name : #AsyncSpreadSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'sinks'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'instance creation' }
AsyncSpreadSink class >> forSinks: aCollectionOfSinks [
	^ self new sinks: aCollectionOfSinks
]

{ #category : #'api - sink' }
AsyncSpreadSink >> cleanSink [
	"Resets the sink to its original state"

	sinks do: #cleanSink
]

{ #category : #initialization }
AsyncSpreadSink >> initialize [
	super initialize.
	
	sinks := #()
]

{ #category : #'api - sink' }
AsyncSpreadSink >> pollClose: anAsynchronousContext [
	"Flush any remaining output and close this sink, if necessary.
	Returns AsyncPoll::Ready(true) when no buffered items remain and the sink has been successfully closed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via cx.waker().wake_by_ref()) to wake up when poll_close should be called again.
	If this function encounters an error, the sink should be considered to have failed permanently, and no more Sink methods should be called."
	<return: #AsyncPoll>
	| isClosed |

	isClosed := sinks allSatisfy: [ :eachSink | (eachSink pollClose: anAsynchronousContext) isReady ].

	^ isClosed
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - sink' }
AsyncSpreadSink >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>

	| isFlushed |

	isFlushed := sinks allSatisfy: [ :eachSink | (eachSink pollFlush: anAsynchronousContext) isReady ].

	^ isFlushed
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - sink' }
AsyncSpreadSink >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	
	| isReady |

	isReady := sinks allSatisfy: [ :eachSink | (eachSink pollReady: anAsynchronousContext) isReady ].

	^ isReady
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - sink' }
AsyncSpreadSink >> sinks: aCollectionOfSinks [
	self
		assert: [ aCollectionOfSinks allSatisfy: [ :eachSink | eachSink notNil ] ]
		description: [ 'Sinks must not be nil' ].

	sinks := aCollectionOfSinks.
	sinks do: [ :eachSink | eachSink parentSink: self ]
]

{ #category : #'api - sink' }
AsyncSpreadSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	sinks do: [ :eachSink | eachSink startSend: anObject ]
]
