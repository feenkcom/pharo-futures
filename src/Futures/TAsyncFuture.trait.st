Trait {
	#name : 'TAsyncFuture',
	#category : 'Futures-Future'
}

{ #category : 'api - future' }
TAsyncFuture >> await [
	^ (AsyncTaskItFutureTask new forFuture: self) future: TKTConfiguration runner
]

{ #category : 'api - future' }
TAsyncFuture >> gtFuture [
	^ self
]

{ #category : 'api - future' }
TAsyncFuture >> map: aBlock [
	^ AsyncMapFuture future: self mapBlock: aBlock
]

{ #category : 'api - future' }
TAsyncFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	self explicitRequirement
]

{ #category : 'api - future' }
TAsyncFuture >> wait [
	| aSemaphore anAwaitResult anAwaitError |
	
	aSemaphore := Semaphore new.
	
	self await
		onSuccessDo: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ];
		onFailureDo: [ :anError |
			anAwaitError := anError freezeOrWithoutContext.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ AsyncFutureError signalForException: anAwaitError ].
	^ anAwaitResult
]
