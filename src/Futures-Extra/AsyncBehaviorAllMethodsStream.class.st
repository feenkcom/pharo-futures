Class {
	#name : #AsyncBehaviorAllMethodsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'behavior',
		'instanceStream',
		'classStream',
		'currentStream'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorAllMethodsStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #accessing }
AsyncBehaviorAllMethodsStream >> behavior: aBehavior [
	behavior := aBehavior.
	instanceStream := AsyncBehaviorInstanceMethodsStream forBehavior: aBehavior.
	classStream := AsyncBehaviorClassMethodsStream forBehavior: aBehavior.
	currentStream := instanceStream
]

{ #category : #'api - stream' }
AsyncBehaviorAllMethodsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	currentStream
		ifNil: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
		
	^ (currentStream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll |
			aReadyPoll value
				ifSome: [ aReadyPoll ]
				ifNone: [
					currentStream == classStream
						ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
					currentStream := classStream.
					currentStream pollNext: anAsynchronousContext ] ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]
