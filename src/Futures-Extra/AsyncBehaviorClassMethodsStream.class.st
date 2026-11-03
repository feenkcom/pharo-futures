Class {
	#name : #AsyncBehaviorClassMethodsStream,
	#superclass : #AsyncBehaviorStream,
	#category : #'Futures-Extra'
}

{ #category : #accessing }
AsyncBehaviorClassMethodsStream >> initializeStream [
	stream := AsyncSequenceStream
			forCollection: [ behavior classSide localSelectors ] asAsyncFuture
]

{ #category : #'api - stream' }
AsyncBehaviorClassMethodsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again.
	The selectors come from a snapshot taken when the stream started, so a method may have been removed after that. Such a selector is skipped, see {{gtMethod:AsyncBehaviorStream>>#pollNextRepeatedly:do:}}."

	<return: #AsyncPoll>
	^ self
		pollNextRepeatedly: anAsynchronousContext
		do: [ :aSelector | 
			(behavior classSide compiledMethodAt: aSelector ifAbsent: [ nil ])
				ifNotNil: [ :aMethod | ^ AsyncPoll ready: (AsyncOptionalValue some: aMethod) ] ]
]
