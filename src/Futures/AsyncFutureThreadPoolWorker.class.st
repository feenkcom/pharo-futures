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
		'workerProcess',
		'futuresCounter',
		'logger'
	],
	#classVars : [
		'DefaultLogger',
		'FuturesCounterClass'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'api - logger' }
AsyncFutureThreadPoolWorker class >> addDefaultLogger: aLogger [
	self defaultLogger: (self defaultLogger composeWith: aLogger)
]

{ #category : #'api - logger' }
AsyncFutureThreadPoolWorker class >> defaultLogger [
	<return: #TAsyncFutureLogger>
	^ DefaultLogger ifNil: [ 
		DefaultLogger := AsyncFutureDetailedTranscriptLogger new ]
]

{ #category : #'api - logger' }
AsyncFutureThreadPoolWorker class >> defaultLogger: aLogger [
	DefaultLogger := aLogger
]

{ #category : #'api - logger' }
AsyncFutureThreadPoolWorker class >> ensureDefaultLogger: aLogger [
	self defaultLogger: (self defaultLogger ensureLogger: aLogger)
]

{ #category : #'api - logger' }
AsyncFutureThreadPoolWorker class >> futuresCounterClass: aClass [
	FuturesCounterClass := aClass
]

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

{ #category : #printing }
AsyncFutureThreadPoolWorker >> gtDisplayOn: aStream [
	super gtDisplayOn: aStream.
	aStream
		nextPut: $(;
		nextPutAll: (self name);
		nextPutAll: ', '.
	priority gtDisplayOn: aStream.
	aStream nextPut: $)
]

{ #category : #initialization }
AsyncFutureThreadPoolWorker >> initialize [
	super initialize.
	
	monitor := Mutex new.
	
	"local queue contains futures that should be executed"
	localQueue := AsyncFutureThreadPoolQueue new.
	pendingQueue := AsyncFutureThreadPoolQueue new.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.

	shouldStop := nil.
	workerProcess := nil.
	currentTask := AsyncOptionalValue none.
	currentTaskProcess := nil.
	
	futuresCounter := FuturesCounterClass
		ifNotNil: [ :aClass | aClass new secondsPerBucket: 2 ].
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

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> isWaitingOnSemaphore [
	"Return true if the worker is waiting on a semaphore, false otherwise."
	<return: #Boolean>

	^ monitor critical: [
		currentTaskProcess
			ifNil: [ false ]
			ifNotNil: [ :aProcess | aProcess suspendingList notNil ] ]
]

{ #category : #debugging }
AsyncFutureThreadPoolWorker >> localItemArray [
	"Just for debugging purposes, e.g., BlScripter.
	Not available for production code use."

	^ localQueue itemArray
]

{ #category : #accessing }
AsyncFutureThreadPoolWorker >> logger [
	<return: #TAsyncFutureLogger>
	^ logger ifNil: [ self class defaultLogger ]
]

{ #category : #accessing }
AsyncFutureThreadPoolWorker >> logger: aLogger [
	logger := aLogger
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> maintanance [
]

{ #category : #printing }
AsyncFutureThreadPoolWorker >> name [
	^ (group ifNotNil: #label ifNil: [ 'undefined group' ])
]

{ #category : #debugging }
AsyncFutureThreadPoolWorker >> pendingItemArray [
	"Just for debugging purposes, e.g., BlScripter.
	Not available for production code use."

	^ pendingQueue itemArray
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> pendingQueueSize [
	
	^ pendingQueue size
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
			self
				telemetrySignalStart: true
				object: anAsyncPendingFuturePromise
				process: Processor activeProcess.
			
			anAsyncPendingFuturePromise isCancelled
				ifTrue: [ self privateRejectCancelledPendingFuture: anAsyncPendingFuturePromise signallingBlock: [
							self
								telemetrySignalStart: false
								object: anAsyncPendingFuturePromise
								process: Processor activeProcess.
							aSemaphore signal ] ]
				ifFalse: [
					pendingQueue pushBack: aPendingTask.

					self
						privateExecutePendingFuture: anAsyncPendingFuturePromise
						storingResultIn: aFutureResultHolder
						signallingBlock: [
							self
								telemetrySignalStart: false
								object: anAsyncPendingFuturePromise
								process: Processor activeProcess.
							aSemaphore signal ] ].
		] newProcess
			priority: self priority asPharoProcessPriority - 1;
			name: 'Future: ', self name.
		
		AsyncProcessProperties
			process: currentTaskProcess
			property: #parentProcess
			put: Processor activeProcess.
		currentTaskProcess resume ].

	[
		| isPending |
		isPending := aSemaphore waitTimeoutSeconds: 60.
		isPending ifTrue: [
			self logger pendingTask: aPendingTask ].
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
				ifPending: [ "it is already in the queue" ] ].

	self telemetryDo: [ :aTelemetry | aTelemetry done: anAsyncPendingFuturePromise worker: self ].
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateExecuteNextFuture [
	self privateExecuteFuture: localQueue popAndWait
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateExecutePendingFuture: aAsyncPendingFuturePromise storingResultIn: aResultValueHolder signalling: aSemaphore [
	"Errors are explicitly handled and frozen, exceptions are forked and passed"
	| aWaker aContext wasRejected |
	
	wasRejected := false.
	
	aWaker := AsyncFutureThreadPoolWaker new
		worker: self;
		task: aAsyncPendingFuturePromise.
	
	aContext := AsyncFutureExecutionContext new
		waker: aWaker.
	
	[ [ [ self privatePollFuture: aAsyncPendingFuturePromise during: [
		| aFutureResult |
		aFutureResult := aAsyncPendingFuturePromise future poll: aContext.

		"we must `return` the result before signalling the semaphore, otherwise the waiting process will continue before result is return from the method"
		aResultValueHolder at: 1 put: aFutureResult.

		aFutureResult
			ifReady: [ :aResultValue | aAsyncPendingFuturePromise fulfillWithValue: aResultValue value ]
			ifPending: [ :aPendingPoll | "it is already in the queue"
				aPendingPoll isPendingIndefinitely
					ifTrue: [ aAsyncPendingFuturePromise notifyPotentiallyIndefinitelyPending ] ].
		
		aSemaphore signal
	] ]
	on: Error do: [ :anError |
		wasRejected := true.
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withException: anError
			signalling: aSemaphore
	] ]
	"Unhandled exceptions are passed, they mean the system is now broken - we need a debugger"
	on: UnhandledException do: [ :anUnhandledException |
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withUnhandledException: anUnhandledException
			signalling: aSemaphore
			ifRejected: wasRejected ] ]
	"Exceptions are not errors, they may even return a value, that is why we do not reject the promise, it may still be fulfilled later.
	However, we should signal the semaphore to unblock the worker"
	on: Exception do: [ :anException |
		aSemaphore signal.
		anException pass ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateExecutePendingFuture: aAsyncPendingFuturePromise storingResultIn: aResultValueHolder signallingBlock: aSemaphoreBlock [
	"Errors are explicitly handled and frozen, exceptions are forked and passed"
	| aWaker aContext wasRejected |
	
	wasRejected := false.
	
	aWaker := AsyncFutureThreadPoolWaker new
		worker: self;
		task: aAsyncPendingFuturePromise.
	
	aContext := AsyncFutureExecutionContext new
		waker: aWaker.
	
	[ [ [ self privatePollFuture: aAsyncPendingFuturePromise during: [
		| aFutureResult |
		aFutureResult := aAsyncPendingFuturePromise future poll: aContext.

		"we must `return` the result before signalling the semaphore, otherwise the waiting process will continue before result is return from the method"
		aResultValueHolder at: 1 put: aFutureResult.

		aFutureResult
			ifReady: [ :aResultValue | aAsyncPendingFuturePromise fulfillWithValue: aResultValue value ]
			ifPending: [ :aPendingPoll | "it is already in the queue"
				aPendingPoll isPendingIndefinitely
					ifTrue: [ aAsyncPendingFuturePromise notifyPotentiallyIndefinitelyPending ] ].
		
		aSemaphoreBlock value
	] ]
	on: Error do: [ :anError |
		wasRejected := true.
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withException: anError
			signallingBlock: aSemaphoreBlock
	] ]
	"Unhandled exceptions are passed, they mean the system is now broken - we need a debugger"
	on: UnhandledException do: [ :anUnhandledException |
		self
			privateRejectPendingFuture: aAsyncPendingFuturePromise
			withUnhandledException: anUnhandledException
			signallingBlock: aSemaphoreBlock
			ifRejected: wasRejected ] ]
	"Exceptions are not errors, they may even return a value, that is why we do not reject the promise, it may still be fulfilled later.
	However, we should signal the semaphore to unblock the worker"
	on: Exception do: [ :anException |
		aSemaphoreBlock value.
		anException pass ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privatePollFuture: aAsyncPendingFuturePromise during: aBlock [
	^ self
		telemetryDo: [ :aTelemetry |
			aTelemetry
				polled: aAsyncPendingFuturePromise
				worker: self
				during: aBlock ]
		ifNone: aBlock
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
AsyncFutureThreadPoolWorker >> privateRejectCancelledPendingFuture: anAsyncPendingFuturePromise signallingBlock: aSemaphoreBlock [
	"Error handling is a user code that we should handle"
	
	[ anAsyncPendingFuturePromise rejectWithCancellation ]
		on: Error
		do: [ :anError |
			aSemaphoreBlock value.
			anError pass ].
	
	"If rejecting error happened without problems we signal the semaphore normally"
	aSemaphoreBlock value
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

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateRejectPendingFuture: aAsyncPendingFuturePromise withException: anException signallingBlock: aSemaphoreBlock [
	"Error handling is a user code that we should handle"

	[ aAsyncPendingFuturePromise rejectWithError: anException ]
		on: Error
		do: [ :anError |
			aSemaphoreBlock value.
			anError pass ].
	
	"If rejecting error happened without problems we signal the semaphore normally"
	aSemaphoreBlock value
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateRejectPendingFuture: aAsyncPendingFuturePromise withUnhandledException: anUnhandledException signalling: aSemaphore ifRejected: wasAlreadyRejected [
	"Error handling is a user code that we should handle"

	wasAlreadyRejected
		"If promise was already rejected it means we already signalled a semaphore, do nothing here and just pass an error"
		ifTrue: [ anUnhandledException pass ]
		ifFalse: [
			"If the promise is not rejected yet it means we didn't handle an error and this is our first try.
			We give promise a chance to handle the error, if it does not work we pass."
			[ aAsyncPendingFuturePromise rejectWithError: anUnhandledException. aSemaphore signal ]
				on: Error
				do: [ :anError |
					aSemaphore signal.
					anError pass ] ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateRejectPendingFuture: aAsyncPendingFuturePromise withUnhandledException: anUnhandledException signallingBlock: aSemaphoreBlock ifRejected: wasAlreadyRejected [
	"Error handling is a user code that we should handle"

	wasAlreadyRejected
		"If promise was already rejected it means we already signalled a semaphore, do nothing here and just pass an error"
		ifTrue: [ anUnhandledException pass ]
		ifFalse: [
			"If the promise is not rejected yet it means we didn't handle an error and this is our first try.
			We give promise a chance to handle the error, if it does not work we pass."
			[ aAsyncPendingFuturePromise rejectWithError: anUnhandledException. aSemaphoreBlock value ]
				on: Error
				do: [ :anError |
					aSemaphoreBlock value.
					anError pass ] ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateSchedule: anAsyncPendingFuturePromise forced: isForcedToSchedule [
	"Return true if the promised future was scheduled, false otherwise.
	If a worker is not running or is shutting down, the scheduling is forbidden"
	<return: #Boolean>
	
	anAsyncPendingFuturePromise isCancelled
		ifTrue: [
			anAsyncPendingFuturePromise rejectWithCancellation.
			^ false ]
		ifFalse: [ anAsyncPendingFuturePromise worker: self ].

	^ monitor critical: [
		(isForcedToSchedule or: [ self acceptsFutures ])
			ifFalse: [ ^ false ].

		localQueue pushBack: anAsyncPendingFuturePromise.
		futuresCounter ifNotNil: [ futuresCounter ping ].
		
		true ]
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> privateUnschedule: anAsyncPendingFuturePromise [
	"Must be called from within the critical block.
	
	Return true of a given promise was cleanly unscheduled, meaning that is wasn't being executed"
	<return: #Boolean>

	localQueue pop: anAsyncPendingFuturePromise.
	^ (pendingQueue popSuchThat: [ :eachPendingTask | eachPendingTask task == anAsyncPendingFuturePromise ])
		ifNil: [ true ]
		ifNotNil: [
			currentTask
				ifSome: [ :aPendingTask | aPendingTask task ~~ anAsyncPendingFuturePromise ]
				ifNone: [ ^ true ] ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> privateWakeUpWorkerLoop [
	"Wake up the worker loop by enqueuing a future that does nothing"
	
	monitor critical: [ localQueue pushBack: (AsyncFuturePromise new future: #wakeup asAsyncFuture) ]
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> schedule: anAsyncPendingFuturePromise [
	"Return true if the promised future was scheduled, false otherwise.
	If a worker is not running or is shutting down, the scheduling is forbidden"
	<return: #Boolean>
	
	^ self
		privateSchedule: anAsyncPendingFuturePromise
		forced: false
]

{ #category : #'api - lifecycle' }
AsyncFutureThreadPoolWorker >> shutdown [
	"Request the worker to shutdown and return a promise which is resolved as soon as the worker is shutdown.
	When in the shutting down state, the worker does not allow new futures to be scheduled and will wait
	until all futures are processed before shutting down"
	<return: #TAsyncPromise>
	| aShutdownPromise |
	
	aShutdownPromise := AsyncFuturePromise new future: #shutdown asAsyncFuture.
	
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

	aStartupPromise := AsyncFuturePromise new future: #startup asAsyncFuture.
	self schedule: aStartupPromise.
	^ aStartupPromise
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> telemetryDo: aBlock [
	^ self telemetryDo: aBlock ifNone: [ nil ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolWorker >> telemetryDo: aBlock ifNone: aNoneBlock [
	^ threadPool
		ifNotNil: [ :aThreadPool | aThreadPool telemetryDo: aBlock ifNone: aNoneBlock ]
		ifNil: aNoneBlock
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolWorker >> telemetrySignalStart: isStart object: anObject process: aProcess [
	<primitive: 'primitiveTelemetryObjectSignal'>
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
	"Return true of a given promise was cleanly unscheduled, meaning that is wasn't being executed"
	<return: #Boolean>

	"if it was in the local queue it means that the worker didn't start to process it yet"
	(localQueue pop: anAsyncPendingFuturePromise)
		ifNotNil: [ :aPromise | ^ true ].

	"if the promise is not in the local queue, it means that it is being executed or is about to be executed"
	^ self privateUnschedule: anAsyncPendingFuturePromise
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
	
	"We do not want users to be able to interrupt worker process as it can block the system"
	#GlutinIgnoreDuringInterruptStatus asClassIfPresent: [ :aClass |
		aClass value: true].
	
	[ monitor critical: [ shouldStop notNil and: [ localQueue isEmpty and: [ pendingQueue isEmpty ] ] ] ] whileFalse: [
			self maintanance.
			self privateExecuteNextFuture ]
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
