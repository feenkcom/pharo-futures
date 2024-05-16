Class {
	#name : #AsyncFutureCompositeLogger,
	#superclass : #Object,
	#traits : 'TAsyncFutureLogger',
	#classTraits : 'TAsyncFutureLogger classTrait',
	#instVars : [
		'loggers'
	],
	#category : #'Futures-Executor - Logger'
}

{ #category : #converting }
AsyncFutureCompositeLogger >> composeWith: aLogger [
	self logger: aLogger.
	^ self
]

{ #category : #testing }
AsyncFutureCompositeLogger >> includesLogger: aLogger [
	^ self loggers anySatisfy: [ :eachLogger | eachLogger includesLogger: aLogger ]
]

{ #category : #accessing }
AsyncFutureCompositeLogger >> logger: aLogger [
	self loggers: (self loggers copyWith: aLogger)
]

{ #category : #accessing }
AsyncFutureCompositeLogger >> loggers [
	^ loggers ifNil: [ #() ]
]

{ #category : #accessing }
AsyncFutureCompositeLogger >> loggers: aCollection [
	loggers := aCollection
]

{ #category : #logging }
AsyncFutureCompositeLogger >> pendingTask: aPendingTask [
	self loggers do: [ :eachLogger | eachLogger pendingTask: aPendingTask ]
]
