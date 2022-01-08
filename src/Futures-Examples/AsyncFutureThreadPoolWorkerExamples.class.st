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

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> newWorker [
	<gtExample>
	<after: #cleanUp>
	
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
	| aWorker aPendingFuturePromise |

	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: [ 1 / 0 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait class equals: ZeroDivide.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
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

	aPendingFuturePromise := AsyncPendingFuturePromise new future: [ true asString . Halt now . 2 + 2 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait class equals: 84.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInNewWorker [
	<gtExample>
	| aWorker aPendingFuturePromise |

	aWorker := self newWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInRunningWorker [
	<gtExample>
	| aWorker aPendingFuturePromise |

	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait equals: 42.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInShutdownWorker [
	<gtExample>
	| aWorker aPendingFuturePromise |

	aWorker := self shutdownNewWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: 42 asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> scheduleInShuttingDownWorker [
	<gtExample>
	| aWorker aPendingFuturePromise aShutdownPromise |

	aPendingFuturePromise := AsyncPendingFuturePromise new future: 42 asAsyncFuture.

	aWorker := self startupNewWorker.
	aShutdownPromise := aWorker shutdown.

	self assert: (aWorker schedule: aPendingFuturePromise) not.

	self assert: aShutdownPromise wait equals: #shutdown.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleNotificationInRunningWorker [
	<gtExample>
	| aWorker aPendingFuturePromise |

	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: [ AsyncFutureExampleNotification new signal ] asAsyncFuture.
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
	| aWorker aPendingFuturePromise |

	aWorker := self startupNewWorker.

	aPendingFuturePromise := AsyncPendingFuturePromise new future: [ (AsyncFutureExampleNotificationWithReturnValue new value: 42) signal * 2 ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	self assert: aPendingFuturePromise wait equals: 84.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #'examples - exceptions' }
AsyncFutureThreadPoolWorkerExamples >> scheduleUnhandledExceptionInRunningWorker [
	<gtExample>
	| aWorker aPendingFuturePromise aResult |

	aWorker := self startupNewWorker.
	
	aPendingFuturePromise := AsyncPendingFuturePromise new future: [ AsyncFutureExampleUnhandledException signal ] asAsyncFuture.
	self assert: (aWorker schedule: aPendingFuturePromise).
	
	"an exception is passed after we signal the promise semaphore"
	aResult := aPendingFuturePromise wait.

	self assert: aResult class equals: AsyncFutureExampleUnhandledException.
	self assert: aResult isFrozen equals: true.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> shutdownNewWorker [
	<gtExample>
	| aWorker aShutdownPromise |
	
	aWorker := self newWorker.
	aShutdownPromise := aWorker shutdown.
	self assert: aShutdownPromise wait equals: #notRunning.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> shutdownRunningWorker [
	<gtExample>
	| aWorker aShutdownPromise |
	
	aWorker := self startupNewWorker.
	aShutdownPromise := aWorker shutdown.
	self assert: aShutdownPromise wait equals: #shutdown.

	self assert: aWorker isRunning not.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures not.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]

{ #category : #examples }
AsyncFutureThreadPoolWorkerExamples >> startupNewWorker [
	<gtExample>
	| aWorker aStartPromise |

	aWorker := self newWorker.
	aStartPromise := aWorker startup.
	self assert: aStartPromise wait equals: #startup.

	self assert: aWorker isRunning.
	self assert: aWorker isShuttingDown not.
	self assert: aWorker isBusy not.
	self assert: aWorker acceptsFutures.
	self assert: aWorker amountOfFutures equals: 0.

	^ aWorker
]
