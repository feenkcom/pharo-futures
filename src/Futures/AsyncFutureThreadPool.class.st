Class {
	#name : #AsyncFutureThreadPool,
	#superclass : #Object,
	#traits : 'TAsyncFutureExecutor',
	#classTraits : 'TAsyncFutureExecutor classTrait',
	#instVars : [
		'workers',
		'maxWorkers'
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

{ #category : #ui }
AsyncFutureThreadPool >> gtWorkersFor: aView [
	<gtView>
	
	^ aView columnedList
		title: 'Workers';
		priority: 10;
		items: [ workers asArray withIndexCollect: [ :each :index | each -> index ] ];
		column: 'Worker' text: [ :each | each value ];
		column: 'Tasks' text: [ :each | each key amountOfFutures ];
		column: 'Busy' text: [ :each | each key isBusy ];
		column: 'Running' text: [ :each | each key isRunning ];
		send: [ :each | each key ];
		actionUpdateButton
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
	anAsyncPendingFuturePromise isCancelled
		ifTrue: [
			anAsyncPendingFuturePromise rejectWithCancellation.
			^ self ].

	(self pickWorkerFor: anAsyncPendingFuturePromise)
		schedule: anAsyncPendingFuturePromise
]

{ #category : #'api - execution' }
AsyncFutureThreadPool >> shutdown [
	workers do: [ :eachWorker | eachWorker shutdown ]
]
