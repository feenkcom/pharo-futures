Class {
	#name : #AsyncObservableValue,
	#superclass : #Object,
	#traits : 'TAsyncStream + TAsyncSink',
	#classTraits : 'TAsyncStream classTrait + TAsyncSink classTrait',
	#instVars : [
		'item',
		'waker',
		'sinks'
	],
	#category : #'Futures-Base - Synthesis'
}

{ #category : #'instance creation' }
AsyncObservableValue class >> new [
	^ self observer
		setupStreamSelf;
		yourself
]

{ #category : #'instance creation' }
AsyncObservableValue class >> observe: anAsyncStream [
	^ self observer
		setupStream: anAsyncStream;
		yourself
]

{ #category : #'instance creation' }
AsyncObservableValue class >> observer [
	^ self basicNew
		initialize;
		yourself
]

{ #category : #converting }
AsyncObservableValue >> asAsyncObservable [
	^ self
]

{ #category : #'api - obervable' }
AsyncObservableValue >> ifSome: aBlock [
	^ item value ifSome: aBlock
]

{ #category : #'api - obervable' }
AsyncObservableValue >> ifSome: aSomeBlock ifNone: aNoneBlock [
	^ item value ifSome: aSomeBlock ifNone: aNoneBlock
]

{ #category : #initialization }
AsyncObservableValue >> initialize [
	super initialize.

	waker := AsyncFutureExecutionAtomicWaker new.
	item := AsyncPollValueHolder new.
	sinks := AsyncSharedWeakOrderedCollection new
]

{ #category : #'api - obervable' }
AsyncObservableValue >> observe [
	"Create a new observer of this value which is a stream that becomes ready when the value of the observable changes"
	<return: #TAsyncStream>
	| anObserver |

	anObserver := AsyncObservableValue observer.
	self ifSome: [ :aValue | anObserver value: aValue ].
	sinks add: anObserver.

	^ anObserver
]

{ #category : #'api - obervable' }
AsyncObservableValue >> observe: anAsyncSink [
	"Use provided sink as an observer instead of creating a new one"
	<return: #TAsyncSink>
	| anObserver |

	anObserver := anAsyncSink.
	self ifSome: [ :aValue | anAsyncSink startSend: aValue ].
	sinks add: anObserver.
	^ anObserver
]

{ #category : #'api - sink' }
AsyncObservableValue >> pollClose: anAsynchronousContext [
	"Flush any remaining output and close this sink, if necessary.
	Returns AsyncPoll::Ready(true) when no buffered items remain and the sink has been successfully closed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via cx.waker().wake_by_ref()) to wake up when poll_close should be called again.
	If this function encounters an error, the sink should be considered to have failed permanently, and no more Sink methods should be called."
	<return: #AsyncPoll>
	| isReady |
	
	isReady := true.
	sinks do: [ :eachSink | isReady := (eachSink pollClose: anAsynchronousContext) isReady and: [ isReady ] ].	
	^ isReady
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - sink' }
AsyncObservableValue >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	| isReady |
	
	isReady := true.
	sinks do: [ :eachSink | isReady := (eachSink pollFlush: anAsynchronousContext) isReady and: [ isReady ] ].	
	^ isReady
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - stream' }
AsyncObservableValue >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ item poll
		ifSome: [ :aValue | AsyncPoll ready: (AsyncOptionalValue some: aValue) ]
		ifNone: [
			waker register: anAsynchronousContext waker.
			AsyncPoll pending ]
]

{ #category : #'api - sink' }
AsyncObservableValue >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	| isReady |
	
	isReady := true.
	sinks do: [ :eachSink | isReady := (eachSink pollReady: anAsynchronousContext) isReady and: [ isReady ] ].	
	^ isReady
		ifTrue: [ AsyncPoll ready: true ]
		ifFalse: [ AsyncPoll pending ]
]

{ #category : #'api - stream copy' }
AsyncObservableValue >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	waker := AsyncFutureExecutionAtomicWaker new.
	item := AsyncPollValueHolder new.
	sinks := AsyncSharedWeakOrderedCollection new
]

{ #category : #initialization }
AsyncObservableValue >> setupStream: aStream [
	((AsyncWeakStream forStream: aStream) forward: self) await
		"Do not use block closures here, otherwise it will start to leak"
		then: #yourself
		otherwise: #debug
]

{ #category : #initialization }
AsyncObservableValue >> setupStreamSelf [
	self setupStream: self
]

{ #category : #'api - sink' }
AsyncObservableValue >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."

	self value: anObject.
	sinks do: [ :eachSink | eachSink startSend: anObject ]
]

{ #category : #'api - obervable' }
AsyncObservableValue >> value: anObject [
	(item value: anObject)
		ifTrue: [ waker wakeUp ]
]

{ #category : #'api - obervable' }
AsyncObservableValue >> valueOrNil [
	"Return the current value if it exists or nil otherwise"
	<return: #Object or: nil>

	^ self
		ifSome: [ :aValue | aValue ]
		ifNone: [ nil ]
]
