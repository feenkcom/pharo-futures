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
TAsyncStream >> collect [
	"Transforms a stream into an Array, returning a future representing the result of that computation."
	<return: #TAsyncFuture>

	^ self collectAs: Array
]

{ #category : #'api - stream' }
TAsyncStream >> collectAs: aClass [
	"Transforms a stream into a collection, returning a future representing the result of that computation."
	<return: #TAsyncFuture>

	^ AsyncStreamCollectFuture stream: self species: aClass
]

{ #category : #'api - stream' }
TAsyncStream >> do: aBlock [
	"Do something with each item of this stream, afterwards passing it on."

	^ self map: [ :eachItem | aBlock value: eachItem. eachItem ]
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

{ #category : #'api - stream' }
TAsyncStream >> fuse [
	^ AsyncFuseStream stream: self
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
