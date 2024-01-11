Class {
	#name : #AsyncThrottleStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'timeout',
		'last',
		'previousPollTime',
		'stream'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncThrottleStream class >> forStream: aStream [
	^ self new stream: aStream
]

{ #category : #initialization }
AsyncThrottleStream >> initialize [
	super initialize.
	
	timeout := 100 milliSeconds.
	previousPollTime := DateAndTime now.
	last := AsyncOptionalValue none.
	stream := nil
]

{ #category : #'api - stream' }
AsyncThrottleStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	| timeElapsed aCurrentPoll anEmittedValue |
	
	"Quick return if the stream is done and last item was emitted"
	(stream isDone and: [ last isNone ])
		ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
	
	(last isSome and: [ (DateAndTime now - previousPollTime) >= timeout ])
		ifTrue: [
			"time has arrived and the value is known"
			previousPollTime := DateAndTime now.
			anEmittedValue := last.
			last := AsyncOptionalValue none.

			^ AsyncPoll ready: anEmittedValue ].
		
	[
		aCurrentPoll := stream pollNext: anAsynchronousContext.
	] doWhileTrue: [
		aCurrentPoll
			ifReady: [ :aReadyPoll |
				"we continue as long as timeout is reached and unless stream finished"
				aCurrentPoll value isSome and: [ (DateAndTime now - previousPollTime) < timeout ] ]
			"if pending we stop"
			ifPending: [ :aPendingPoll |
				false ] ].
	
	aCurrentPoll ifReady: [ :aReadyPoll |
		aReadyPoll value isSome
			ifTrue: [ last := aReadyPoll value ] ].

	"the stream is done"
	(stream isDone and: [ last isNone ])
		ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
	
	"stream is not ready"
	last isNone
		ifTrue: [ ^ aCurrentPoll ].

	timeElapsed := DateAndTime now - previousPollTime.
	timeElapsed < timeout
		"time didn't arrive yet"
		ifTrue: [
			TaskAtQueue default
				schedule: [ anAsynchronousContext waker wakeUp ]
				at: previousPollTime + timeElapsed
				entryIdentifier: self.
			^ AsyncPoll pending ].

	self
		assert: [ last isSome ]
		description: [ 'Value must be known here' ].
	
	"time has arrived and the value is known"
	previousPollTime := DateAndTime now.
	anEmittedValue := last.
	last := AsyncOptionalValue none.

	^ AsyncPoll ready: anEmittedValue
]

{ #category : #'api - stream copy' }
AsyncThrottleStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"

	stream := stream asyncSimilarCopy.
	last := AsyncOptionalValue none.
	previousPollTime := DateAndTime now.
]

{ #category : #initialization }
AsyncThrottleStream >> stream: aStream [
	stream := aStream fuse
]

{ #category : #accessing }
AsyncThrottleStream >> timeout [

	^ timeout
]

{ #category : #accessing }
AsyncThrottleStream >> timeout: aDuration [
	timeout := aDuration
]
