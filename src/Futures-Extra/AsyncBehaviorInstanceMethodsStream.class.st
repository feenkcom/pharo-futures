Class {
	#name : #AsyncBehaviorInstanceMethodsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'behavior',
		'stream'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorInstanceMethodsStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #initialization }
AsyncBehaviorInstanceMethodsStream >> behavior: aBehavior [
	behavior := aBehavior.
	stream := AsyncSequenceStream forCollection: [ behavior localSelectors ] asAsyncFuture
]

{ #category : #'api - stream' }
AsyncBehaviorInstanceMethodsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	stream ifNil: [
		^ AsyncPoll ready: AsyncOptionalValue none ].
	
	^ (stream pollNext: anAsynchronousContext)
		map: [ :aSelectorOption |
			aSelectorOption map: [ :aSelector |
				behavior
					compiledMethodAt: aSelector
					ifAbsent: [ ^ AsyncPoll pending ] ] ]
]
