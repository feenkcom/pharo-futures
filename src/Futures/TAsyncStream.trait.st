Trait {
	#name : 'TAsyncStream',
	#category : 'Futures-Streams'
}

{ #category : 'api - stream' }
TAsyncStream >> collect [
	"Transforms a stream into a collection, returning a future representing the result of that computation."
	<return: #TAsyncFuture>

	^ AsyncStreamCollectFuture stream: self
]

{ #category : 'api - stream' }
TAsyncStream >> filter: aFilterBlock [
	"Filters the values produced by this stream according to the provided asynchronous predicate."
	<return: #TAsyncStream>

	^ AsyncFilterStream stream: self filter: aFilterBlock
]

{ #category : 'api - stream' }
TAsyncStream >> flatten [
	^ AsyncFlattenStream stream: self
]

{ #category : 'api - stream' }
TAsyncStream >> map: aMapBlock [
	<return: #TAsyncStream>

	^ AsyncMapStream stream: self mapBlock: aMapBlock
]

{ #category : 'api - stream' }
TAsyncStream >> next [
	"Creates a future that resolves to the next item in the stream."
	<return: #TAsyncFuture>

	^ AsyncStreamNextFuture stream: self
]

{ #category : 'api - stream' }
TAsyncStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ self explicitRequirement
]

{ #category : 'api - stream' }
TAsyncStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ AsyncStreamSizeHint unknown
]

{ #category : 'api - stream' }
TAsyncStream >> take: anAmount [
	"Creates a new stream of at most anAmount items of the underlying stream."
	<return: #TAsyncStream>

	^ AsyncTakeStream stream: self amount: anAmount
]
