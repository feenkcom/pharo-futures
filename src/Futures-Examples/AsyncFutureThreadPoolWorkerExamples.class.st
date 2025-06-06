Class {
	#name : #AsyncFutureThreadPoolWorkerExamples,
	#superclass : #Object,
	#instVars : [
		'worker'
	],
	#category : #'Futures-Examples'
}

{ #category : #cleanup }
AsyncFutureThreadPoolWorkerExamples >> cleanUp [
	worker ifNotNil: [ worker shutdown wait ]
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> hardCancelScheduledInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aSemaphore aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aSemaphore := Semaphore new.
	aPendingFuturePromise := AsyncFuturePromise new
			future: [ aSemaphore signal.
				10 seconds wait.
				42 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).

	aSemaphore wait.	"Hard cancellation terminates the currently running future"
	aPendingFuturePromise
		cancel: AsyncFutureExecutionHardCancellation uniqueInstance.

	self assert: aPendingFuturePromise wait class equals: AsyncFutureCancelled.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> newWorker [
	<gtExample>
	<after: #cleanUp>
	<return: #AsyncFutureThreadPoolWorker>
	worker ifNotNil: [ ^ worker ].

	worker := AsyncFutureThreadPoolWorker new.
	self assert: worker isRunning not.
	self assert: worker isShuttingDown not.
	self assert: worker isBusy not.
	self assert: worker acceptsFutures not.
	self assert: worker amountOfFutures equals: 0.

	^ worker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleErroneousInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: [ 1 / 0 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait class equals: ZeroDivide.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleHaltInRunningWorker [
	<gtExample>
	"No test, because halt opens a debugger"
	<noTest>
	| aWorker aPendingFuturePromise |

	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: [ true asString . Halt now . 2 + 2 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait class equals: Halt.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> scheduleHardCancelledInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.
	aPendingFuturePromise
		cancel: AsyncFutureExecutionHardCancellation uniqueInstance.

	self assert: (aWorker schedule: aPendingFuturePromise) not.
	self assert: aPendingFuturePromise wait class equals: AsyncFutureCancelled.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInNewWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self newWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait equals: 42.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInShutdownWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self shutdownNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInShuttingDownWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise aShutdownPromise |
	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.

	aWorker := self startupNewWorker.
	aShutdownPromise := aWorker shutdown.

	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aShutdownPromise wait equals: #shutdown.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleNotificationInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new
			future: [ AsyncFutureExampleNotification new signal ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait equals: nil.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleNotificationWithReturnValueInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new
			future: [ (AsyncFutureExampleNotificationWithReturnValue new value: 42) signal * 2 ]
					asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait equals: 84.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> scheduleSoftCancelledInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: 42 asAsyncFuture.
	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	self assert: (aWorker schedule: aPendingFuturePromise) not.
	self assert: aPendingFuturePromise wait class equals: AsyncFutureCancelled.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleUnhandledExceptionInRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aPendingFuturePromise aResult |
	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncFuturePromise new
			future: [ AsyncFutureExampleUnhandledException signal ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).	"an exception is passed after we signal the promise semaphore"
	aResult := aPendingFuturePromise wait.

	self assert: aResult class equals: AsyncFutureExampleUnhandledException.
	self assert: aResult isFrozen equals: true.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> shutdownNewWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aShutdownPromise |
	aWorker := self newWorker.
	aShutdownPromise := aWorker shutdown.
	self assert: aShutdownPromise wait equals: #notRunning.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> shutdownRunningWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aShutdownPromise |
	aWorker := self startupNewWorker.
	aShutdownPromise := aWorker shutdown.
	self assert: aShutdownPromise wait equals: #shutdown.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> softCancelExecutedButPendingInRunningWorker [
	<gtExample>
	<return: #AsyncFuturePromise>
	| aWorker aPendingFuturePromise |
	aWorker := self newWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: AsyncPendingFuture new.
	self assert: (aWorker privateSchedule: aPendingFuturePromise forced: true).
	self assert: aPendingFuturePromise worker equals: aWorker.

	aWorker privateExecuteNextFuture.

	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.
	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	^ aPendingFuturePromise
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> softCancelExecutedButPendingInRunningWorkerThenFulfill [
	<gtExample>
	<return: #AsyncFuturePromise>
	| aWorker aPendingFuturePromise |
	aWorker := self newWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: AsyncPendingFuture new.
	self assert: (aWorker privateSchedule: aPendingFuturePromise forced: true).
	self assert: aPendingFuturePromise worker equals: aWorker.

	aWorker privateExecuteNextFuture.

	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	aPendingFuturePromise fulfillWithValue: 42.

	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	^ aPendingFuturePromise
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> softCancelExecutedButPendingInRunningWorkerThenReject [
	<gtExample>
	<return: #AsyncFuturePromise>
	| aWorker aPendingFuturePromise |
	aWorker := self newWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: AsyncPendingFuture new.
	self assert: (aWorker privateSchedule: aPendingFuturePromise forced: true).
	self assert: aPendingFuturePromise worker equals: aWorker.

	aWorker privateExecuteNextFuture.

	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	aPendingFuturePromise rejectWithError: Error new.

	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	^ aPendingFuturePromise
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> softCancelExecutedButPendingInRunningWorkerTwice [
	<gtExample>
	<return: #AsyncFuturePromise>
	| aWorker aPendingFuturePromise |
	aWorker := self newWorker.

	aPendingFuturePromise := AsyncFuturePromise new future: AsyncPendingFuture new.
	self assert: (aWorker privateSchedule: aPendingFuturePromise forced: true).
	self assert: aPendingFuturePromise worker equals: aWorker.

	aWorker privateExecuteNextFuture.

	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	self assert: aPendingFuturePromise isCancelled.
	self assert: aPendingFuturePromise isRejected.

	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	^ aPendingFuturePromise
]

{ #category : #'examples - cancellation' }
AsyncFutureThreadPoolWorkerExamples >> softCancelScheduledInRunningWorker [
	<gtExample>
	<return: #AsyncFuturePromise>
	| aWorker aSemaphore aPendingFuturePromise |
	aWorker := self startupNewWorker.

	aSemaphore := Semaphore new.
	aPendingFuturePromise := AsyncFuturePromise new
			future: [ aSemaphore signal.
				42 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).

	aSemaphore wait.	"Soft cancellation allows currently executing running future to finish"
	aPendingFuturePromise
		cancel: AsyncFutureExecutionSoftCancellation uniqueInstance.

	self assert: aPendingFuturePromise wait equals: 42.

	self assert: aPendingFuturePromise isCancelled not.
	self assert: aPendingFuturePromise isFulfilled.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aPendingFuturePromise
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> startupNewWorker [
	<gtExample>
	<return: #AsyncFutureThreadPoolWorker>
	| aWorker aStartPromise |
	aWorker := self newWorker.
	aStartPromise := aWorker startup.
	self assert: aStartPromise wait equals: #startup.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]
