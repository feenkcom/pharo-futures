Class {
	#name : #AsyncAbstractWrappedStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Extra'
}

{ #category : #'api - stream' }
AsyncAbstractWrappedStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ stream pollNext: anAsynchronousContext
]

{ #category : #private }
AsyncAbstractWrappedStream >> pollNextRepeatedly: anAsynchronousContext do: aBlock [
	"Poll the inner stream until the block answers a result. The block is evaluated with every value of the inner stream and has the responsibility to interrupt the cycle:
	- answer a result by a non-local return `^ AsyncPoll ready: (AsyncOptionalValue some: aResult)`,
	- do nothing if the value should be skipped, e.g., it is not available anymore. The inner stream is then polled again.
	Do not answer a pending poll for a skipped value. Nothing would wake the stream up, because the inner stream has already consumed the value, and the stream would never finish.
	A pending poll of the inner stream is answered as it is. When the inner stream is exhausted, this stream is exhausted too."

	<return: #AsyncPoll>
	stream ifNil: [ ^ AsyncPoll ready: AsyncOptionalValue none ].

	[ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll | 
			aReadyPoll value
				ifSome: [ :aValue | aBlock cull: aValue ]
				ifNone: [ ^ AsyncPoll ready: AsyncOptionalValue none ] ]
		ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] repeat
]
