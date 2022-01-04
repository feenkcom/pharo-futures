Class {
	#name : #AsyncFutureThreadPoolWorker,
	#superclass : #Object,
	#instVars : [
		'localQueue',
		'pendingQueue',
		'waker',
		'process',
		'shouldStop'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> executeTask: anAsyncFutureExecutionTask [
	| aContext aWaker aSemaphore aFutureResult |
	
	aWaker := AsyncFutureThreadPoolWaker new
		worker: self;
		task: anAsyncFutureExecutionTask.
	
	aContext := AsyncFutureExecutionContext new
		waker: aWaker.
	
	aSemaphore := Semaphore new.
	[
		aFutureResult := [ anAsyncFutureExecutionTask future poll: aContext ]
			on: Exception
			do: [ :anException |
				aSemaphore signal.
				aFutureResult := nil.
				anException pass ].
		aSemaphore signal ] forkAt: Processor userBackgroundPriority.

	aSemaphore wait.

	"Failed to execute the future"
	aFutureResult
		ifNil: [ ^ self ].

	aFutureResult
		ifReady: [ :aResultValue | anAsyncFutureExecutionTask result: aResultValue ]
		ifPending: [ pendingQueue pushBack: anAsyncFutureExecutionTask ]
]

{ #category : #initialization }
AsyncFutureThreadPoolWorker >> initialize [
	super initialize.
	
	"local queue contains futures that should be executed"
	localQueue := AsyncFutureThreadPoolQueue new.
	pendingQueue := AsyncFutureThreadPoolQueue new.
	
	shouldStop := false
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> maintanance [
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> schedule: anAsyncFutureExecutionTask [
	localQueue pushBack: anAsyncFutureExecutionTask
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> shutdown [
	shouldStop := true
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> startup [
	self
		assert: [ process isNil ]
		description: [ 'Worker process already exists' ].

	process := [ self workerLoop ] newProcess
		priority: Processor userSchedulingPriority - 5;
		name: 'Futures worker';
		resume
]

{ #category : #'api - worker' }
AsyncFutureThreadPoolWorker >> wakeUp: anAsyncFutureExecutionTask [
	"Wake up the worker by placing all pending futures into a local queue.
	Can be executed from an arbitrary process"
	
	(pendingQueue pop: anAsyncFutureExecutionTask)
		ifNotNil: [ :aTask | localQueue pushBackAll: aTask ]
]

{ #category : #'private - process' }
AsyncFutureThreadPoolWorker >> workerLoop [
	"Execute tasks until asked to stop"

	[ shouldStop ] whileFalse: [
		self maintanance.
		self executeTask: localQueue popAndWait ]
]
