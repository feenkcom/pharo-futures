Class {
	#name : #AsyncDelayedFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future',
		'delay',
		'startTime'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncDelayedFuture class >> forFuture: anAsyncFuture delay: aDuration [
	^ self new
		future: anAsyncFuture
		delay: aDuration
]

{ #category : #initialization }
AsyncDelayedFuture >> future: anAsyncFuture delay: aDuration [
	future := anAsyncFuture.
	delay := aDuration
]

{ #category : #'api - future' }
AsyncDelayedFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	startTime ifNil: [ startTime := DateAndTime now ].
	
	(DateAndTime now - startTime) < delay
		ifTrue: [
			TaskAtQueue default
				schedule: [ anAsynchronousContext waker wakeUp ]
				at: startTime + delay
				entryIdentifier: self.
			^ AsyncPoll pending ]
	
		ifFalse: [ ^ future poll: anAsynchronousContext ]
]

{ #category : #'api - future copy' }
AsyncDelayedFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy.
	startTime := nil.
]

{ #category : #private }
AsyncDelayedFuture >> waitDuration [
	^ DateAndTime now - (startTime ifNil:[ DateAndTime now ])
]
