Class {
	#name : #AsyncFutureThreadPool,
	#superclass : #Object,
	#traits : 'TAsyncFutureExecutor',
	#classTraits : 'TAsyncFutureExecutor classTrait',
	#instVars : [
		'workers',
		'maxWorkers',
		'telemetry'
	],
	#classInstVars : [
		'current'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #cleanup }
AsyncFutureThreadPool class >> cleanUp [
	<script: 'self cleanUp'>
	current ifNotNil: [ :aThreadPool | aThreadPool shutdown ].
	current := nil
]

{ #category : #accessing }
AsyncFutureThreadPool class >> current [
	^ current ifNil:[ current := self new ]
]

{ #category : #initialization }
AsyncFutureThreadPool >> initialize [
	super initialize.
	
	workers := AsyncSharedOrderedCollection new.
	maxWorkers := 10
]

{ #category : #'private - execution' }
AsyncFutureThreadPool >> pickWorkerFor: aAsyncFutureThreadPoolTask [
	| runningWorkers |
	
	runningWorkers := workers select: [ :eachWorker |
		eachWorker acceptsFutures and: [
			eachWorker group = aAsyncFutureThreadPoolTask group
				and: [ eachWorker priority = aAsyncFutureThreadPoolTask priority ] ] ].

	runningWorkers := runningWorkers sorted: [ :a :b | a amountOfFutures < b amountOfFutures ].

	runningWorkers
		detect: [ :eachWorker | eachWorker isBusy not and: [ eachWorker acceptsFutures and: [ eachWorker amountOfFutures isZero ] ] ]
		ifFound: [ :aWorker | ^ aWorker ]
		ifNone: [
			| anAllowedMaxWorkers |

			anAllowedMaxWorkers := aAsyncFutureThreadPoolTask group isUnspecified
				ifTrue: [ maxWorkers ]
				ifFalse: [ 1 ].

			runningWorkers size < anAllowedMaxWorkers
				ifTrue: [
					| aNewWorker |

					aNewWorker := AsyncFutureThreadPoolWorker new
						threadPool: self;
						priority: aAsyncFutureThreadPoolTask priority;
						group: aAsyncFutureThreadPoolTask group.
					aNewWorker startup.
					workers add: aNewWorker.
					^ aNewWorker ]
				ifFalse: [
					^ runningWorkers
						detect: [ :eachWorker | eachWorker isBusy not ]
						ifFound: [ :aWorker | aWorker ]
						ifNone: [ runningWorkers first ] ] ]
]

{ #category : #'api - execution' }
AsyncFutureThreadPool >> schedule: anAsyncPendingFuturePromise [
	| aWorker |
	anAsyncPendingFuturePromise isCancelled
		ifTrue: [
			anAsyncPendingFuturePromise rejectWithCancellation.
			^ self ].

	aWorker := (self pickWorkerFor: anAsyncPendingFuturePromise).
	(aWorker schedule: anAsyncPendingFuturePromise)
		ifFalse: [ ^ self ].

	self telemetryDo: [ :aTelemetry | aTelemetry scheduled: anAsyncPendingFuturePromise worker: aWorker ]
]

{ #category : #'api - execution' }
AsyncFutureThreadPool >> shutdown [
	workers do: [ :eachWorker | eachWorker shutdown ]
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPool >> telemetry: aTelemetry [
	telemetry := aTelemetry asWeakReference
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPool >> telemetryDo: aBlock [
	^ self telemetryDo: aBlock ifNone: [ nil ]
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPool >> telemetryDo: aBlock ifNone: aNoneBlock [
	^ telemetry
		ifNotNil: [ :aWeakTelemetry |
			(aWeakTelemetry at: 1)
				ifNotNil: aBlock
				ifNil: aNoneBlock ]
		ifNil: aNoneBlock
]
