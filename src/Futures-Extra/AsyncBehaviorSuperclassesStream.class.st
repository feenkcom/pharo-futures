Class {
	#name : #AsyncBehaviorSuperclassesStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'behavior',
		'currentSuperclass'
	],
	#category : #'Futures-Extra'
}

{ #category : #'instance creation' }
AsyncBehaviorSuperclassesStream class >> forBehavior: aBehavior [
	^ self new behavior: aBehavior
]

{ #category : #accessing }
AsyncBehaviorSuperclassesStream >> behavior: aBehavior [
	behavior := aBehavior.
	currentSuperclass := AsyncOptionalValue none
]

{ #category : #'api - stream' }
AsyncBehaviorSuperclassesStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>

	^ currentSuperclass
		ifSome: [ :aSuperclass |
			| aNextSuperclass |
			aNextSuperclass := aSuperclass superclass.
			(aNextSuperclass isNil or: [ aNextSuperclass = aSuperclass ])
					ifTrue: [ AsyncPoll ready: AsyncOptionalValue none ]
					ifFalse: [
						currentSuperclass := AsyncOptionalValue some: aNextSuperclass.
						AsyncPoll ready: currentSuperclass ] ]
		ifNone: [
			| aNextSuperclass |
			aNextSuperclass := behavior superclass.
			(aNextSuperclass isNil or: [ aNextSuperclass = behavior ])
				ifFalse: [ currentSuperclass := AsyncOptionalValue some: aNextSuperclass ].
			AsyncPoll ready: currentSuperclass ]
]

{ #category : #'api - stream copy' }
AsyncBehaviorSuperclassesStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	currentSuperclass := AsyncOptionalValue none
]
