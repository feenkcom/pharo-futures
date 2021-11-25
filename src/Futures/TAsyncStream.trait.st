"
#Asynchronous Stream
A stream of values produced asynchronously.

If {{gtClass:TAsyncFuture}} is an asynchronous version of {{gtClass:Object}}, then {{gtClass:TAsyncStream}} is an asynchronous version of Iterator. A stream represents a sequence of value-producing events that occur asynchronously to the caller.
The trait is modeled after {{gtClass:TAsyncFuture}}, but allows {{gtMethod:TAsyncStream>>#pollNext:}} to be called even after a value has been produced, yielding {{gtClass:AsyncNoneValue}} once the stream has been fully exhausted.
"
Trait {
	#name : #TAsyncStream,
	#category : #'Futures-Base - Streams'
}

{ #category : #'api - stream' }
TAsyncStream >> asAsyncStream [
	^ self
]

{ #category : #'api - stream copy' }
TAsyncStream >> asyncSimilarCopy [
	"Answer another stream of the same type that is not yet polled.
	This is different from #copy, which would potentially create a copy of the stream
	in the same state as the copied stream"
	<return: #TAsyncStream>

	^ self shallowCopy postSimilarCopy
]

{ #category : #'api - stream' }
TAsyncStream >> cached [
	"Returns a stream that caches items across all #asyncSimilarCopy streams.
	Correctly handles the case when each similar stream is polled from a difference worker process,
	the cache is shared and synchronised between such streams."
	<return: #TAsyncStream>

	^ AsyncCachedStream forStream: self
]

{ #category : #'api - stream' }
TAsyncStream >> chunks: aCapacity [
	"An adaptor for chunking up items of the stream inside a vector.
	This combinator will attempt to pull items from this stream and buffer them into a local vector.
	At most `capacity` items will get buffered before they're yielded from the returned stream. Note that
	the vectors returned from this iterator may not always have `capacity` elements. If the underlying
	stream ended and only a partial vector was created, it'll be returned. Additionally if an error happens
	from the underlying stream then the currently buffered items will be yielded."
	<return: #TAsyncStream>

	^ AsyncChunksStream forStream: self capacity: aCapacity
]

{ #category : #'api - stream' }
TAsyncStream >> collect: aMapBlock [
	"An alias to TAsyncStream>>#map:"
	<return: #TAsyncStream>

	^ self map: aMapBlock
]

{ #category : #'api - stream' }
TAsyncStream >> do: aBlock [
	"Alias to TAsyncSteam>>#forEach:"
	<return: #TAsyncFuture>

	^ self forEach: aBlock
]

{ #category : #'api - stream' }
TAsyncStream >> filter: aFilterBlock [
	"Filters the values produced by this stream according to the provided asynchronous predicate."
	<return: #TAsyncStream>

	^ AsyncFilterStream stream: self filter: aFilterBlock
]

{ #category : #'api - stream' }
TAsyncStream >> flatten [
	^ AsyncFlattenStream stream: self
]

{ #category : #accessing }
TAsyncStream >> for: aDuration [
	<return: #TAsyncStream>

	^ AsyncWithTimeoutStream stream: self for: aDuration
]

{ #category : #'api - stream' }
TAsyncStream >> forEach: aBlock [
	"Runs this stream to completion, executing the provided asynchronous closure for each element on the stream.
	The closure provided will be called for each item this stream produces,
	yielding a future. That future will then be executed to completion
	before moving on to the next item."
	<return: #TAsyncFuture>

	^ AsyncStreamForEachFuture forStream: self block: aBlock
]

{ #category : #'api - stream' }
TAsyncStream >> fuse [
	^ AsyncFuseStream forStream: self
]

{ #category : #'api - stream' }
TAsyncStream >> hasNext [
	"Creates a future that resolves to true if the #next item is polled succesfully and it is not none"
	<return: #TAsyncFuture>

	^ AsyncStreamHasNextFuture stream: self
]

{ #category : #'api - stream' }
TAsyncStream >> inject: anInitialValue into: aBinaryBlock [
	"Execute an accumulating asynchronous computation over a stream, collecting all the values into one final result.
	This combinator will accumulate all values returned by this stream according to the closure provided. The initial state is also provided to this method and then is returned again by each execution of the closure. Once the entire stream has been exhausted the returned future will resolve to this value."

	^ AsyncStreamFoldFuture
		forStream: self
		initialValue: anInitialValue
		block: aBinaryBlock
]

{ #category : #'api - testing' }
TAsyncStream >> isAsyncStream [
	^ true
]

{ #category : #'api - stream' }
TAsyncStream >> map: aMapBlock [
	<return: #TAsyncStream>

	^ AsyncMapStream stream: self mapBlock: aMapBlock
]

{ #category : #'api - stream' }
TAsyncStream >> merge: aStream [
	^ (AsyncSequenceStream forCollection: { self . aStream }) flatten
]

{ #category : #'api - stream' }
TAsyncStream >> next [
	"Creates a future that resolves to the next item in the stream."
	<return: #TAsyncFuture>

	^ AsyncStreamNextFuture stream: self
]

{ #category : #'api - stream' }
TAsyncStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ self explicitRequirement
]

{ #category : #'api - stream copy' }
TAsyncStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
]

{ #category : #'api - stream' }
TAsyncStream >> select: aFilterBlock [
	"An alias to TAsyncStream>>#filter:"
	<return: #TAsyncStream>

	^ self filter: aFilterBlock
]

{ #category : #'api - stream' }
TAsyncStream >> sizeHint [
	<return: #AsyncStreamSizeHint>

	^ AsyncStreamSizeHint unknown
]

{ #category : #'api - stream' }
TAsyncStream >> take: anAmount [
	"Creates a new stream of at most anAmount items of the underlying stream."
	<return: #TAsyncStream>

	^ AsyncTakeStream stream: self amount: anAmount
]

{ #category : #'api - stream' }
TAsyncStream >> terminatable [
	"Creates a new Terminatable stream. When #terminate is sent to the terminatable stream, the stream will complete immediately without making any further progress.
	Please note, that if the #terminate is sent while a stream is being polled, the stream will finish the current polling step."
	<return: #TAsyncStream>

	^ AsyncTerminatableStream forStream: self
]

{ #category : #'api - stream' }
TAsyncStream >> to: aClass [
	"Transforms a stream into a collection, returning a future representing the result of that computation."
	<return: #TAsyncFuture>

	^ AsyncStreamCollectFuture stream: self species: aClass
]

{ #category : #'api - stream' }
TAsyncStream >> toArray [
	"Transforms a stream into an Array, returning a future representing the result of that computation."
	<return: #TAsyncFuture>

	^ self to: Array
]

{ #category : #'api - stream' }
TAsyncStream >> withoutDuplicates [
	^ AsyncWithoutDuplicatesStream forStream: self
]
