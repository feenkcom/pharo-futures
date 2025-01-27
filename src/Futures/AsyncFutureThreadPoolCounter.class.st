"
Counts how many time something happened within the last minute
"
Class {
	#name : #AsyncFutureThreadPoolCounter,
	#superclass : #Object,
	#instVars : [
		'mutex',
		'time',
		'secondsPerBucket',
		'amountOfBuckets',
		'previousSeconds',
		'pings'
	],
	#category : #'Futures-Executor - Telemetry'
}

{ #category : #'instance creation' }
AsyncFutureThreadPoolCounter class >> withTime: aTime [
	^ self basicNew
		setTime: aTime;
		initialize;
		yourself
]

{ #category : #accessing }
AsyncFutureThreadPoolCounter >> amountOfPings [
	^ mutex critical: [
		self flushAndGetCurrentBucket.
		pings sum ]
]

{ #category : #private }
AsyncFutureThreadPoolCounter >> flushAndGetCurrentBucket [
	| currentBucket elapsedSeconds totalSeconds |
	totalSeconds := self totalSeconds.
	elapsedSeconds := totalSeconds - previousSeconds.
	currentBucket := totalSeconds % 60 // secondsPerBucket + 1.

	elapsedSeconds >= 120
		ifTrue: [
			pings atAllPut: 0.
			previousSeconds := totalSeconds - (totalSeconds % 60) + ((currentBucket - 1) * secondsPerBucket) ]
		ifFalse: [ elapsedSeconds >= 60
				ifTrue: [
					| bucketsToFlush forwardBuckets backwardBuckets |
					bucketsToFlush := (elapsedSeconds // secondsPerBucket) + 1 - amountOfBuckets.
					backwardBuckets := bucketsToFlush min: currentBucket.
					forwardBuckets := bucketsToFlush - backwardBuckets.
					
					currentBucket - backwardBuckets + 1
						to: currentBucket
						do: [ :i | pings at: i put: 0 ].
					
					amountOfBuckets 
						to: amountOfBuckets - forwardBuckets + 1
						by: -1
						do: [ :i | pings at: i put: 0 ].
					
					previousSeconds := totalSeconds - (totalSeconds % 60) + ((currentBucket - amountOfBuckets) * secondsPerBucket) ] ].

	^ currentBucket
]

{ #category : #initialization }
AsyncFutureThreadPoolCounter >> initialize [
	super initialize.
	
	mutex := AsyncDeadlockSafeMonitor new.
	time ifNil: [ time := Time ].
	self secondsPerBucket: 5.
	previousSeconds := self totalSeconds
]

{ #category : #accessing }
AsyncFutureThreadPoolCounter >> ping [
	mutex critical: [
		| currentBucket |
		currentBucket := self flushAndGetCurrentBucket.
		pings at: currentBucket put: (pings at: currentBucket) + 1 ]
]

{ #category : #private }
AsyncFutureThreadPoolCounter >> pingsArray [
	^ pings
]

{ #category : #accessing }
AsyncFutureThreadPoolCounter >> pingsTimeline [
	^ mutex critical: [
		| currentBucket previousPings offset |
		
		currentBucket := self flushAndGetCurrentBucket.
		previousPings := Array new: pings size.
		
		(currentBucket + 1
			to: amountOfBuckets)
			withIndexDo: [ :v :i | previousPings at: i put: (pings at: v) ].
		
		offset := amountOfBuckets - currentBucket.
		
		(1 to: currentBucket)
			withIndexDo: [ :v :i | previousPings at: (i + offset) put: (pings at: v) ].
		
		^ previousPings ]
]

{ #category : #private }
AsyncFutureThreadPoolCounter >> previousSeconds [
	^ previousSeconds
]

{ #category : #initialization }
AsyncFutureThreadPoolCounter >> secondsPerBucket: aNumber [	
	secondsPerBucket := aNumber.
	amountOfBuckets := (60 // secondsPerBucket).
	
	self
		assert: [ 60 % secondsPerBucket = 0 ]
		description: [ 'There must be a decimal amount of buckets' ].

	pings := WordArray new: amountOfBuckets
]

{ #category : #initialization }
AsyncFutureThreadPoolCounter >> setTime: aTime [
	time := aTime
]

{ #category : #private }
AsyncFutureThreadPoolCounter >> totalSeconds [
	^ time totalSeconds
]
