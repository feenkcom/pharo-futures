Class {
	#name : #AsyncFutureExecutionWakerState,
	#superclass : #Object,
	#instVars : [
		'previousState'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionWakerState >> previousState [
	^ previousState
]

{ #category : #accessing }
AsyncFutureExecutionWakerState >> previousState: anObject [
	previousState := anObject
]

{ #category : #'as yet unclassified' }
AsyncFutureExecutionWakerState >> registeredState [
	^ AsyncFutureExecutionWakerRegisteredState new
		previousState: self
]

{ #category : #'as yet unclassified' }
AsyncFutureExecutionWakerState >> unregisteredState [
	^ AsyncFutureExecutionWakerUnregisteredState new
		previousState: self
]

{ #category : #'as yet unclassified' }
AsyncFutureExecutionWakerState >> wokenUpState [
	^ AsyncFutureExecutionWakerWokenWithoutWakerState new
		previousState: self
]
