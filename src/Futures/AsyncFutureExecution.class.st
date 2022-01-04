Class {
	#name : #AsyncFutureExecution,
	#superclass : #TKTFutureExecution,
	#category : #'Futures-Executor - TaskIt'
}

{ #category : #evaluating }
AsyncFutureExecution >> doExecuteTask [

	timeout ifNotNil:
		[ TKTConfiguration runner scheduleTimeout: timeout on: self ].
	[
		| aPoll |
		aPoll := task value.
		aPoll
			ifReady: [ future deploySuccess: aPoll value ]
			ifPending: [ runner scheduleTaskExecution: self copy ] ]
		on: Error
		do: [ :error | future deployFailure: error freeze ].
]

{ #category : #copying }
AsyncFutureExecution >> postCopy [
	state := TKTReadyTaskState new.
	cancelled := nil.
	executionProcess := nil.
	isRunning := nil
]
