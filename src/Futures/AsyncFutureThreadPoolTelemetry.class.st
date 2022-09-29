Class {
	#name : #AsyncFutureThreadPoolTelemetry,
	#superclass : #Object,
	#instVars : [
		'announcer',
		'events'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> done: anAsyncPendingFuturePromise worker: aWorker [
	events nextPut: (AsyncFutureThreadPoolTelemetryDoneEvent new promise: anAsyncPendingFuturePromise worker: aWorker)
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolTelemetry >> eventsForWorker: aWorker [
	^ events itemArray
		select: [ :eachItem | eachItem isZombie not and: [ eachItem object worker == aWorker ] ]
		thenCollect: [ :eachItem | eachItem object ]
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetry >> initialize [
	super initialize.
	
	events := WaitfreeQueue new
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> polled: anAsyncPendingFuturePromise worker: aWorker during: aBlock [
	| anEvent aResult |
	
	anEvent := AsyncFutureThreadPoolTelemetryPolledEvent new promise: anAsyncPendingFuturePromise worker: aWorker.
	aResult := aBlock value.
	anEvent endTime: DateAndTime now.
	events nextPut: anEvent.

	^ aResult
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetry >> reset [
	events flush
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> scheduled: anAsyncPendingFuturePromise worker: aWorker [
	events nextPut: (AsyncFutureThreadPoolTelemetryScheduledEvent new promise: anAsyncPendingFuturePromise worker: aWorker)
]
