Class {
	#name : 'AsyncFutureExecution',
	#superclass : 'TKTFutureExecution',
	#category : 'Futures-Executor'
}

{ #category : 'evaluating' }
AsyncFutureExecution >> doExecuteTask [
	[
		| aPoll |
		aPoll := task value.
		aPoll
			ifReady: [ future deploySuccess: aPoll value ]
			ifPending: [ runner scheduleTaskExecution: self copy ] ]
		on: Error
		do: [ :error | future deployFailure: error freezeOrWithoutContext ].
]

{ #category : 'copying' }
AsyncFutureExecution >> postCopy [
	state := TKTReadyTaskState new.
	cancelled := nil.
	executionProcess := nil.
	isRunning := nil
]
