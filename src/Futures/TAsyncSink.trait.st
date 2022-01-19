"
#Asynchronous Sink

In the `Futures` library we define a {{gtClass:TAsyncFuture}} as an asynchrnous computation and a {{gtClass:TAsyncPromise}} as an object into which a value may be sent either as a result of a Future computation or by manually fulfilling a promise with a value.

Similarly to the Promise, a Sink is a value into which other values can be sent, asynchronously, for example taken from a {{gtClass:TAsyncStream}}.
Basic examples of sinks include the sending side of:
 - Channels
 - Sockets
 - Pipes
In addition to such ""primitive"" sinks, it's typical to layer additional functionality, such as buffering, on top of an existing sink.

Sending to a sink is ""asynchronous"" in the sense that the value may not be sent in its entirety immediately. Instead, values are sent in a two-phase way: first by initiating a send, and then by polling for completion. This two-phase setup is analogous to buffered writing in synchronous code, where writes often succeed immediately, but internally are buffered and are actually written only upon flushing. In addition, the Sink may be full, in which case it is not even possible to start the sending process.

As with Future and Stream, the Sink trait is built from a few core required methods, and a host of default methods for working in a higher-level way. The {{gtMethod:TAsyncSink>>#sendAll:}}combinator is of particular importance: you can use it to send an entire stream to a sink, which is the simplest way to ultimately consume a stream.
"
Trait {
	#name : #TAsyncSink,
	#category : #'Futures-Base - Sinks'
}

{ #category : #'api - sink' }
TAsyncSink >> cleanSink [
	"Resets the sink to its original state"
]

{ #category : #'api - sink' }
TAsyncSink >> close [
	"Returns a future that closes this sink. Closing a sink does not necessarily mean that the sink will no longer receive items."
	<return: #TAsyncFuture>

	^ AsyncSinkCloseFuture forSink: self
]

{ #category : #'api - sink' }
TAsyncSink >> fanout: anotherSink [
	"Fanout items to multiple sinks.
	The fanout sink forwards each incoming item to both this as well as the other sink at the same time."
	<return: #TAsyncSink>

	^ AsyncFanoutSink forSinkA: self sinkB: anotherSink
]

{ #category : #'api - sink' }
TAsyncSink >> isAsyncSink [
	^ true
]

{ #category : #'api - sink' }
TAsyncSink >> pollClose: anAsynchronousContext [
	"Flush any remaining output and close this sink, if necessary.
	Returns AsyncPoll::Ready(true) when no buffered items remain and the sink has been successfully closed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via cx.waker().wake_by_ref()) to wake up when poll_close should be called again.
	If this function encounters an error, the sink should be considered to have failed permanently, and no more Sink methods should be called."
	<return: #AsyncPoll>
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
TAsyncSink >> pollFlush: anAsynchronousContext [
	"Flush any remaining output from this sink.
	Returns Poll::Ready(true) when no buffered items remain. If this value is returned then it is guaranteed that all previous values sent via #startSend: have been flushed.
	Returns Poll::Pending if there is more work left to do, in which case the current task is scheduled (via waker) to wake up when #pollFlush: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>

	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
TAsyncSink >> pollReady: anAsynchronousContext [
	"Attempts to prepare the Sink to receive a value.
	This method must be called and return Poll::Ready(true) prior to each call to start_send.
	This method returns Poll::Ready once the underlying sink is ready to receive data. If this method returns Poll::Pending, the current task is registered to be notified (via waker) when #pollReady: should be called again.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	<return: #AsyncPoll>
	
	^ AsyncPoll ready: true
]

{ #category : #'api - sink' }
TAsyncSink >> sendAll: aStream [
	"Return a future that completes after the given stream has been fully processed into the sink, including flushing.
	The future will drive the stream to keep producing items until it is exhausted, sending each item to the sink.
	It will complete once both the stream is exhausted, the sink has received all items, and the sink has been flushed.
	
	Note that the sink is not cloed. If the stream produces an error, that error will be returned by this future without flushing the sink."
	<return: #TAsyncFuture>

	^ AsyncSinkSendAllFuture forSink: self stream: aStream asAsyncStream
]

{ #category : #'api - sink' }
TAsyncSink >> startSend: anObject [
	"Begin the process of sending a value to the sink. Each call to this function must be preceded by a successful call to pollReady which returned Poll::Ready(true).
	As the name suggests, this method only begins the process of sending the item. If the sink employs buffering, the item isn't fully processed until the buffer is fully flushed. Since sinks are designed to work with asynchronous I/O, the process of actually writing out the data to an underlying object takes place asynchronously. You must use #pollFlush: or #pollClose: in order to guarantee completion of a send.
	Implementations of #pollReady: and #startSend: will usually involve flushing behind the scenes in order to make room for new messages. It is only necessary to call #pollFlush: if you need to guarantee that all of the items placed into the Sink have been sent.
	In most cases, if the sink encounters an error, the sink will permanently be unable to receive items."
	
	self explicitRequirement
]
