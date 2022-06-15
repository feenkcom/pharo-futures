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

{ #category : #private }
AsyncDelayedFuture >> waitDuration [
	^ DateAndTime now - (startTime ifNil:[ DateAndTime now ])
]
