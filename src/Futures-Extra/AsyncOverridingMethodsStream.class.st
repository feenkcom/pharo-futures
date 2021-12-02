Class {
	#name : #AsyncOverridingMethodsStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'compiledMethod',
		'stream'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncOverridingMethodsStream class >> forCompiledMethod: aCompiledMethod [
	^ self new compiledMethod: aCompiledMethod
]

{ #category : #initialization }
AsyncOverridingMethodsStream >> compiledMethod: aCompiledMethod [
	compiledMethod := aCompiledMethod.
	stream := ((AsyncBehaviorAllSubclassesStream forBehavior: compiledMethod methodClass)
		collect: [ :eachBehavior | eachBehavior compiledMethodAt: compiledMethod selector ifAbsent: [ nil ] ])
			select: [ :eachMethod | eachMethod notNil ]
]

{ #category : #'api - stream' }
AsyncOverridingMethodsStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ stream pollNext: anAsynchronousContext
]

{ #category : #'api - stream copy' }
AsyncOverridingMethodsStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	self compiledMethod: compiledMethod
]
