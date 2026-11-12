"
I give every test or example its own {{gtClass:AsyncFutureThreadPool}}.
I exist because promises ({{gtMethod:TAsyncFuture>>#await:}}) normally run on the single global pool ({{gtMethod:AsyncFutureThreadPool class>>#current}}), whose worker processes are not forked by the test that scheduled a promise. Such promises would not see the test's {{gtClass:TestExecutionEnvironment}}, would share workers with tests running in parallel, and a worker created during a test would be terminated by {{gtClass:ProcessMonitorTestService}} while staying in the global pool.
As a {{gtClass:TestExecutionService}}, I am registered automatically in every {{gtClass:TestExecutionEnvironment}}. {{gtMethod:AsyncFutureThreadPool class>>#forCurrentExecutionEnvironment}} asks the active environment for its pool ({{gtMethod:TestExecutionEnvironment>>#asyncFutureThreadPool}}), and the environment answers my {{gtMethod:AsyncFutureThreadPoolTestService>>#threadPool}}. I create it lazily, so tests without promises pay nothing. Its workers are forked from test processes and therefore inherit the test environment, including nested promises.
{{gtMethod:AsyncFutureThreadPoolTestService>>#cleanUpAfterTest}} terminates its worker processes, rejects its unfinished promises with cancellation ({{gtMethod:AsyncFutureThreadPool>>#terminateWorkers}}), and forgets it, so the next test or example gets a new pool.
See {{gtClass:GtExamplesForExecutionEnvironmentInPromises}} for examples.
"
Class {
	#name : #AsyncFutureThreadPoolTestService,
	#superclass : #TestExecutionService,
	#instVars : [
		'threadPool',
		'mutex'
	],
	#category : #'Futures-SUnit-Executor - Test Support'
}

{ #category : #controlling }
AsyncFutureThreadPoolTestService >> cleanUpAfterTest [
	"Terminate the workers of the test's thread pool, cancel its unfinished promises, and forget it,
	so that the next test gets a new one.
	Cancellation callbacks may schedule new futures and so create a new pool; repeat a few times to dispose of it too"

	super cleanUpAfterTest.

	3
		timesRepeat: [ | aThreadPool |
			aThreadPool := mutex
					critical: [ | aPool |
						aPool := threadPool.
						threadPool := nil.
						aPool ].
			aThreadPool ifNotNil: [ :aPool | aPool terminateWorkers ] ]
]

{ #category : #debugging }
AsyncFutureThreadPoolTestService >> handleNewProcess: aProcess [
	"A temporary check"

	super handleNewProcess: aProcess.

	ProcessMonitorTestServiceNewProcessSignal new
		service: self;
		process: aProcess;
		emit.

	self
		assert: [ aProcess isKindOf: Process ]
		description: [ 'New process must be kind of Process' ]
]

{ #category : #testing }
AsyncFutureThreadPoolTestService >> hasThreadPool [
	<return: #Boolean>
	^ mutex critical: [ threadPool notNil ]
]

{ #category : #initialization }
AsyncFutureThreadPoolTestService >> initialize [
	super initialize.

	mutex := Mutex new
]

{ #category : #accessing }
AsyncFutureThreadPoolTestService >> threadPool [
	"Answer the thread pool of the running test or example, creating it on first use"

	<return: #AsyncFutureThreadPool>
	^ mutex
		critical: [ threadPool ifNil: [ threadPool := AsyncFutureThreadPool new ] ]
]
