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
AsyncFutureThreadPoolWorker >> privateExecuteFuture: anAsyncPendingFuturePromise [
	"Execute a given task from within the worker process"
	| aPendingTask aSemaphore aFutureResultHolder aFutureResult |
	
	aSemaphore := Semaphore new.

	aPendingTask := AsyncFutureThreadPoolPendingTask new task: anAsyncPendingFuturePromise.

	aFutureResultHolder := Array with: nil.
	
	monitor critical: [
		currentTask := AsyncOptionalValue some: aPendingTask.

		currentTaskProcess := [
			anAsyncPendingFuturePromise isCancelled
				ifTrue: [ self privateRejectCancelledPendingFuture: anAsyncPendingFuturePromise signalling: aSemaphore ]
				ifFalse: [
					pendingQueue pushBack: aPendingTask.

					self
						privateExecutePendingFuture: anAsyncPendingFuturePromise
						storingResultIn: aFutureResultHolder
						signalling: aSemaphore ]
		] forkAt: self priority asPharoProcessPriority - 1 ].

	[
		| isPending |
		isPending := aSemaphore waitTimeoutSeconds: 60.
		isPending ifTrue: [
			NonInteractiveTranscript stdout
				nextPutAll: aPendingTask printString;
				cr ].
		"if the process is terminated, then there is no reason to wait for it even if the semaphore was not signalled "
		isPending := isPending
			and: [ currentTaskProcess isTerminated not ].
		isPending ] whileTrue.

	"At this point the promise is resolved"
	monitor critical: [
		currentTask := AsyncOptionalValue none.
		currentTaskProcess := nil ].

	aFutureResult := aFutureResultHolder at: 1.	
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
AsyncFutureThreadPoolWorker >> privateExecutePendingFuture: aAsyncPendingFuturePromise storingResultIn: aResultValueHolder signalling: aSemaphore [
	"Errors are explicitly handled and frozen, exceptions are forked and passed"
	| aWaker aContext |
	
	aWaker := AsyncFutureThreadPoolWaker new
		worker: self;
		task: aAsyncPendingFuturePromise.
	
	aContext := AsyncFutureExecutionContext new
		waker: aWaker.
	
	[ [ [
		| aFutureResult |
		aFutureResult := aAsyncPendingFuturePromise future poll: aContext.

		"we must `return` the result before signalling the semaphore, otherwise the waiting process will continue before result is return from the method"
		aResultValueHolder at: 1 put: aFutureResult.

		aFutureResult
			ifReady: [ :aResultValue | aAsyncPendingFuturePromise fulfillWithValue: aResultValue value ]
			ifPending: [ "it is already in the queue" ].

		aSemaphore signal
	]
	on: Error do: [ :anError |
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withException: anError
			signalling: aSemaphore
	] ]
	on: UnhandledException do: [ :anUnhandledException |
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withException: anUnhandledException
			signalling: aSemaphore.
		anUnhandledException pass
	] ]
	"Exceptions are not errors, they may even return a value, that is why we do not reject the promise, it may still be fulfilled later.
	However, we should signal the semaphore to unblock the worker"
	on: Exception do: [ :anException |
		aSemaphore signal.
		anException pass ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateRejectCancelledPendingFuture: anAsyncPendingFuturePromise signalling: aSemaphore [
	"Error handling is a user code that we should handle"
	
	[ anAsyncPendingFuturePromise rejectWithCancellation ]
		on: Error
		do: [ :anError |
			aSemaphore signal.
			anError pass ].
	
	"If rejecting error happened without problems we signal the semaphore normally"
	aSemaphore signal
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateRejectPendingFuture: aAsyncPendingFuturePromise withException: anException signalling: aSemaphore [
	"Error handling is a user code that we should handle"

	[ aAsyncPendingFuturePromise rejectWithError: anException ]
		on: Error
		do: [ :anError |
			aSemaphore signal.
			anError pass ].
	
	"If rejecting error happened without problems we signal the semaphore normally"
	aSemaphore signal
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> privateUnschedule: anAsyncPendingFuturePromise [
	"Must be called from within the critical block"

	localQueue pop: anAsyncPendingFuturePromise.
	pendingQueue popSuchThat: [ :eachPendingTask | eachPendingTask task == anAsyncPendingFuturePromise ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateWakeUpWorkerLoop [
	"Wake up the worker loop by enqueuing a future that does nothing"
	
	monitor critical: [ localQueue pushBack: (AsyncPendingFuturePromise new future: #wakeup asAsyncFuture) ]
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> schedule: anAsyncPendingFuturePromise [
	"Return true if the promised future was scheduled, false otherwise.
	If a worker is not running or is shutting down, the scheduling is forbidden"
	<return: #Boolean>
	
	anAsyncPendingFuturePromise isCancelled
		ifTrue: [
			anAsyncPendingFuturePromise rejectWithCancellation.
			^ false ]
		ifFalse: [ anAsyncPendingFuturePromise worker: self ].

	^ monitor critical: [
		self acceptsFutures
			ifFalse: [ ^ false ].

		localQueue pushBack: anAsyncPendingFuturePromise.
		
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

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> terminate: anAsyncPendingFuturePromise [
	monitor critical: [
		| activeContext timeoutContext |

		self privateUnschedule: anAsyncPendingFuturePromise.

		"make sure that there is a process for the task and that the current running task is the one we want to terminate"
		currentTaskProcess ifNil: [ ^ anAsyncPendingFuturePromise rejectWithCancellation ].
		currentTask
			ifSome: [ :aPendingTask |
				aPendingTask task == anAsyncPendingFuturePromise
					ifFalse: [ ^ anAsyncPendingFuturePromise rejectWithCancellation ] ]
			ifNone: [ ^ anAsyncPendingFuturePromise rejectWithCancellation ].

		"#isSuspended may be too broad, ideally we should have something like #isBeingDebugged.
		The suspended check prevents errors when terminating a task that is debugged or suspended due to an exception.
		See https://github.com/feenkcom/gtoolkit/issues/1823"
		currentTaskProcess isSuspended
			ifTrue: [ ^ anAsyncPendingFuturePromise rejectWithCancellation ].
	
		currentTaskProcess == Processor activeProcess
			ifTrue: [ AsyncFutureCancelled new signal ].

		currentTaskProcess suspend.
		activeContext := currentTaskProcess suspendedContext.
		timeoutContext := [ AsyncFutureCancelled new signal ] asContext.
		timeoutContext privSender: activeContext.
		currentTaskProcess suspendedContext: timeoutContext.
		currentTaskProcess priority: (Processor lowIOPriority min: currentTaskProcess priority + 5).
		currentTaskProcess resume ]
]

{ #category : #initialization }
AsyncFutureThreadPoolWorker >> threadPool: anAsyncFutureThreadPool [
	threadPool := anAsyncFutureThreadPool
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> unschedule: anAsyncPendingFuturePromise [
	"if it was in the local queue it means that the worker didn't start to process it yet"
	(localQueue pop: anAsyncPendingFuturePromise)
		ifNotNil: [ :aPromise | ^ aPromise rejectWithCancellation ].

	"if the promise is not in the local queue, it means that it is being executed or is about to be executed"
	self privateUnschedule: anAsyncPendingFuturePromise
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
			self privateExecuteFuture: localQueue popAndWait ]
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
