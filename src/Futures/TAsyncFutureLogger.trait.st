Trait {
	#name : #TAsyncFutureLogger,
	#category : #'Futures-Executor - Logger'
}

{ #category : #converting }
TAsyncFutureLogger >> composeWith: aLogger [
	^ AsyncFutureCompositeLogger new
		loggers: {self. aLogger}
]

{ #category : #converting }
TAsyncFutureLogger >> ensureLogger: aLogger [
	^ (self includesLogger: aLogger) ifTrue: [ self ] ifFalse: [ self composeWith: aLogger ]
]

{ #category : #testing }
TAsyncFutureLogger >> includesLogger: aLogger [
	^ self class = aLogger class
]

{ #category : #logging }
TAsyncFutureLogger >> pendingTask: aPendingTask [
	
]
