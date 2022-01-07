Class {
	#name : #AsyncFutureThreadPoolWorker,
	#superclass : #Object,
	#instVars : [
		'threadPool',
		'monitor',
		'localQueue',
		'pendingQueue',
		'currentTask',
		'shouldStop',
		'priority',
		'group',
		'currentTaskProcess',
		'workerProcess'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> acceptsFutures [
	<return: #Boolean>

	^ self isRunning and: [ self isShuttingDown not ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> amountOfFutures [
	"Return the current amount of future in the local queue, does not take into account
	pending futures within pending queue"
	<return: #Number>

	^ localQueue size
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> group [
	^ group
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> group: aAsyncFutureExecutionGroup [
	self
		assert: [ self isRunning not ]
		description: [ 'Can not change the group of a running worker' ].

	group := aAsyncFutureExecutionGroup
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolWorker >> gtLocalQueueFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Local queue';
		priority: 11;
		object: [ localQueue ];
		view: #gtItemsFor:
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolWorker >> gtPendingQueueFor: aView [
	<gtView>

	^ aView forward
		title: 'Pending queue';
		priority: 12;
		object: [ pendingQueue ];
		view: #gtItemsFor:
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolWorker >> gtShutdownActionFor: anAction [
	<gtAction>

	^ anAction button
		tooltip: 'Shutdown';
		priority: 30;
		icon: BrGlamorousVectorIcons shutdown;
		action: [ self shutdown ]
]

{ #category : #initialization }
AsyncFutureThreadPoolWorker >> initialize [
	super initialize.
	
	monitor := Monitor new.
	
	"local queue contains futures that should be executed"
	localQueue := AsyncFutureThreadPoolQueue new.
	pendingQueue := AsyncFutureThreadPoolQueue new.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.

	shouldStop := nil.
	workerProcess := nil.
	currentTask := AsyncOptionalValue none.
	currentTaskProcess := nil
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> isBusy [
	"Return true if the worker is executing a task, false otherwise.
	When the worker is waiting for a new task or performing a maintanance work it is not considered to be busy"
	<return: #Boolean>

	^ monitor critical: [ currentTask isSome ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> isRunning [
	"Return true if the pool worker is currently running. Please note that the worker is considered running
	even if it is in the process of shutting down, because it still has to finish the execution of all futures"
	<return: #Boolean>

	^ monitor critical: [ workerProcess notNil ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> isShuttingDown [
	"Return true if the worker in the process of shutting down. The shutdown does not happen instantaneously as workers have to wait
	for all futures, including pending, to finish execution."
	<return: #Boolean>

	^ monitor critical: [ shouldStop notNil and: [ workerProcess notNil ] ]
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> maintanance [
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> priority [
	<return: #AsyncFutureExecutionPriority>

	^ priority
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> priority: anAsyncFutureExecutionPriority [
	self
		assert: [ self isRunning not ]
		description: [ 'Can not change the priority of a running worker' ].
		
	priority := anAsyncFutureExecutionPriority
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateExecuteTask: aAsyncPendingFuturePromise [
	"Execute a given task from within the worker process"
	| aPendingTask aContext aWaker aSemaphore aFutureResult |
		
	aPendingTask := AsyncFutureThreadPoolPendingTask new task: aAsyncPendingFuturePromise.
	
	currentTask := AsyncOptionalValue some: aPendingTask.
	
	aWaker := AsyncFutureThreadPoolWaker new
		worker: self;
		task: aAsyncPendingFuturePromise.
	
	aContext := AsyncFutureExecutionContext new
		waker: aWaker.
	
	aSemaphore := Semaphore new.

	currentTaskProcess := [
		aFutureResult := nil.

		"Errors are explicitly handled and frozen, exceptions are forked and passed"
		[ [
				pendingQueue pushBack: aPendingTask.
				aFutureResult := aAsyncPendingFuturePromise future poll: aContext.
				aFutureResult
					ifReady: [ :aResultValue | aAsyncPendingFuturePromise fulfillWithValue: aResultValue value ]
					ifPending: [ "it is already in the queue" ].
				aSemaphore signal
			]
				on: Error
				do: [ :anError |
					"Error handling is a user code that we should handle"
					[ aAsyncPendingFuturePromise rejectWithError: anError ]
						on: Exception
						do: [ :anException |
							aSemaphore signal.
							anException pass ] ] ]
						on: Exception
						do: [ :anException |
							"Error handling is a user code that we should handle"
							[ aAsyncPendingFuturePromise rejectWithError: anException ]
								on: Exception
								fork: [ :anInnerException | anInnerException pass ].
							aSemaphore signal.
							anException pass ]
		] forkAt: self priority asPharoProcessPriority - 1.

	aSemaphore wait.

	currentTask := AsyncOptionalValue none.
	currentTaskProcess := nil.

	aFutureResult
		ifNil: [ 
			"Failed to execute the future"
			pendingQueue pop: aPendingTask ]
		ifNotNil: [
			aFutureResult
				ifReady: [ :aResultValue | pendingQueue pop: aPendingTask ]
				ifPending: [ "it is already in the queue" ] ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateWakeUpWorkerLoop [
	"Wake up the worker loop by enqueuing a future that does nothing"
	
	monitor critical: [ localQueue pushBack: (AsyncPendingFuturePromise new future: #wakeup asAsyncFuture) ]
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> schedule: aAsyncPendingFuturePromise [
	"Return true if the promised future was scheduled, false otherwise.
	If a worker is not running or is shutting down, the scheduling is forbidden"
	<return: #Boolean>

	^ monitor critical: [
		self acceptsFutures
			ifFalse: [ ^ false ].

		localQueue pushBack: aAsyncPendingFuturePromise.
		
		true ]
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> shutdown [
	"Request the worker to shutdown and return a promise which is resolved as soon as the worker is shutdown.
	When in the shutting down state, the worker does not allow new futures to be scheduled and will wait
	until all futures are processed before shutting down"
	<return: #TAsyncPromise>
	| aShutdownPromise |
	
	aShutdownPromise := AsyncPendingFuturePromise new future: #shutdown asAsyncFuture.
	
	monitor critical: [	
		self isRunning
			ifFalse: [ ^ aShutdownPromise fulfillWithValue: #notRunning ].

		self isShuttingDown
			ifTrue: [ ^ aShutdownPromise fulfillWithValue: #shuttingDown ].

		shouldStop := aShutdownPromise.
		self privateWakeUpWorkerLoop ].

	^ aShutdownPromise
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> startup [
	<return: #TAsyncPromise>
	| aStartupPromise |

	monitor critical: [ 
		| aPharoProcess |
		self
			assert: [ workerProcess isNil ]
			description: [ 'Worker process already exists' ].

		aPharoProcess := [
				self workerLoop.
				monitor critical: [
					| aShouldStopPromise |
					aShouldStopPromise := shouldStop.
					workerProcess := nil.
					shouldStop := nil.
					aShouldStopPromise fulfillWithValue: #shutdown ] ] newProcess
			priority: priority asPharoProcessPriority;
			name: self workerProcessName.
	
		workerProcess := AsyncFutureExecutionProcess new
			process: aPharoProcess;
			worker: self.

		AsyncProcessProperties
			reifyProcess: aPharoProcess
			as: workerProcess.

		aPharoProcess resume ].

	aStartupPromise := AsyncPendingFuturePromise new future: #startup asAsyncFuture.
	self schedule: aStartupPromise.
	^ aStartupPromise
]

{ #category : #initialization }
AsyncFutureThreadPoolWorker >> threadPool: anAsyncFutureThreadPool [
	threadPool := anAsyncFutureThreadPool
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> wakeUp: anAsyncFutureExecutionTask [
	"Wake up the worker by placing a pending future into a local queue.
	Can be executed from an arbitrary process"
	
	monitor critical: [
		(pendingQueue popSuchThat: [ :eachPendingTask | eachPendingTask task == anAsyncFutureExecutionTask ])
			ifNotNil: [ :aPendingTask | localQueue pushBack: aPendingTask task ] ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> workerLoop [
	"Execute futures until asked to stop"

	[ monitor critical: [ shouldStop notNil and: [ localQueue isEmpty and: [ pendingQueue isEmpty ] ] ] ] whileFalse: [
			self maintanance.
			self privateExecuteTask: localQueue popAndWait ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> workerProcessLabel [
	^ group label
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> workerProcessName [
	^ String streamContents: [ :aStream |
		aStream
			nextPutAll: 'Futures worker ';
			nextPut: $(;
			nextPutAll: self workerProcessLabel;
			nextPut: $) ]
]
