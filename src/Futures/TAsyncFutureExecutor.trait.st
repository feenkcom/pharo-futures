Trait {
	#name : #TAsyncFutureExecutor,
	#category : #'Futures-Executor'
}

{ #category : #'api - execution' }
TAsyncFutureExecutor >> schedule: aAsyncPendingFuturePromise [
	"Schedule a given promised future for the execution"

	self explicitRequirement
]

{ #category : #'api - execution' }
TAsyncFutureExecutor >> shutdown [
	"Shutdown the executor waiting for all futures to finish"
]
