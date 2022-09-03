Class {
	#name : #AsyncStreamBufferFlushedSink,
	#superclass : #Object,
	#traits : 'TAsyncSink',
	#classTraits : 'TAsyncSink classTrait',
	#instVars : [
		'streamBuffer',
		'initialAmount',
		'loadedAmount'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'api - sink' }
AsyncStreamBufferFlushedSink >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	
	initialAmount ifNil: [ ^ AsyncPoll ready: true ].
	
	streamBuffer announce: (AsyncStreamBufferChanged new newItems: (Array new: loadedAmount); index: initialAmount + 1).
	
	loadedAmount := 0.
	initialAmount := nil.
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
AsyncStreamBufferFlushedSink >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	
	initialAmount ifNil: [ initialAmount := streamBuffer amountOfLoadedItems ].
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
AsyncStreamBufferFlushedSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	loadedAmount := loadedAmount + 1
]

{ #category : #accessing }
AsyncStreamBufferFlushedSink >> streamBuffer [

	^ streamBuffer
]

{ #category : #accessing }
AsyncStreamBufferFlushedSink >> streamBuffer: anObject [
	streamBuffer := anObject.
	initialAmount := nil.
	loadedAmount := 0
]
