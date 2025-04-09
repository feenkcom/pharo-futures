Class {
	#name : #AsyncFutureExecutionWakerRegisteredState,
	#superclass : #AsyncFutureExecutionWakerState,
	#category : #'Futures-Executor'
}

{ #category : #'as yet unclassified' }
AsyncFutureExecutionWakerRegisteredState >> wokenUpState [
	^ AsyncFutureExecutionWakerWokenWithWakerState new
		previousState: self
]
