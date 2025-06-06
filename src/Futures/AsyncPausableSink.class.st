Class {
	#name : #AsyncPausableSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'sink',
		'remaining',
		'waker',
		'promise'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'instance creation' }
AsyncPausableSink class >> forSink: aSink [
	^ self new sink: aSink
]

{ #category : #'api - sink' }
AsyncPausableSink >> cleanSink [
	"Resets the sink to its original state"

	sink cleanSink
]

{ #category : #'private - sink' }
AsyncPausableSink >> fulfillPendingPromise [
	promise lock: [ :anOptionalPromise |
		promise value: AsyncOptionalValue none.
		anOptionalPromise ifSome: [ :aPromise | aPromise fulfillWithValue: true ] ]
]

{ #category : #'api - actions' }
AsyncPausableSink >> pause [
	remaining value: 0.
	waker wakeUp
]

{ #category : #'api - sink' }
AsyncPausableSink >> pollClose: anAsynchronousContext [
	"Flush any remaining output and close this sink, if necessary.
	Returns AsyncPoll::Ready(true) when no buffered items remain and the sink has been successfully closed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via cx.waker().wake_by_ref()) to wake up when poll_close should be called again.
	If this function encounters an error, the sink should be considered to have failed permanently, and no more Sink methods should be called."
	<return: #AsyncPoll>
	
	remaining value: -1.
	self fulfillPendingPromise.

	^ sink pollClose: anAsynchronousContext
]

{ #category : #'api - sink' }
AsyncPausableSink >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>

	^ sink pollFlush: anAsynchronousContext
]

{ #category : #'api - sink' }
AsyncPausableSink >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>

	^ remaining
		lock: [ :aRemaining | 
			aRemaining isZero
				ifTrue: [
					waker register: anAsynchronousContext waker.
					AsyncPoll pending ]
				ifFalse: [ sink pollReady: anAsynchronousContext ] ]
]

{ #category : #'api - actions' }
AsyncPausableSink >> resume: anAmount [
	<return: #TAsyncPromise>
	| returnedPromise |

	returnedPromise := remaining lock: [ :aValue |
		remaining value: (anAmount max: aValue).
		promise lock: [ :anOptionalPromise |
			anOptionalPromise
				ifSome: [ :aPromise | aPromise ]
				ifNone: [
					| newPromise |
					newPromise := AsyncManualPromise new.
					promise value: (AsyncOptionalValue some: newPromise).
					newPromise ] ] ].

	waker wakeUp.

	^ returnedPromise
]

{ #category : #initialization }
AsyncPausableSink >> sink: aSink [
	sink := aSink.
	sink parentSink: self.
	remaining := AsyncMutex for: 0.
	waker := AsyncFutureExecutionAtomicWaker new.
	promise := AsyncMutex for: AsyncOptionalValue none
]

{ #category : #'api - sink' }
AsyncPausableSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."

	remaining lock: [ :aValue | aValue > 0 ifTrue: [ remaining value: (aValue - 1) ] ].

	sink startSend: anObject.
	
	remaining lock: [ :aValue |
		aValue isZero
			ifTrue: [ self fulfillPendingPromise ] ]
]
