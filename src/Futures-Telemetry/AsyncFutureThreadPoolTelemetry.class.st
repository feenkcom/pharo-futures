Class {
	#name : #AsyncFutureThreadPoolTelemetry,
	#superclass : #Object,
	#instVars : [
		'events'
	],
	#category : #'Futures-Telemetry-Telemetry'
}

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetry >> addEvent: anEvent [
	events add: anEvent
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetry >> copyBetween: aStartTime and: anEndDate [
	^ self class new
		setEvents: (events select: [ :each |
			each startTime >= aStartTime and: [ each endTime <= anEndDate ]])
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> done: anAsyncPendingFuturePromise worker: aWorker [
	self addEvent: (AsyncFutureThreadPoolTelemetryDoneEvent new
		promise: anAsyncPendingFuturePromise
		worker: aWorker)
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetry >> eventsByWorker [
	^ ((events
		groupedBy: [ :eachEvent | eachEvent worker ])
		values collect: [ :eachCollectionOfEvents |
			AsyncFutureThreadPoolTelemetryByWorker new events: eachCollectionOfEvents ])
				sorted: [ :a :b | a worker priority asPharoProcessPriority > b worker priority asPharoProcessPriority ]
]

{ #category : #'api - accessing' }
AsyncFutureThreadPoolTelemetry >> eventsForWorker: aWorker [
	^ events select: [ :eachEvent | eachEvent worker == aWorker ]
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetry >> initialize [
	super initialize.
	
	events := AsyncSharedOrderedCollection new
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> polled: anAsyncPendingFuturePromise worker: aWorker during: aBlock [
	| anEvent aResult "aProcessTelemetry" |
	
	anEvent := AsyncFutureThreadPoolTelemetryPolledEvent new
		promise: anAsyncPendingFuturePromise
		worker: aWorker.
	
	"aProcessTelemetry := VirtualMachineThisProcessSwitchTelemetry spyOn: [ aResult := aBlock value ]."
	anEvent endTime: DateAndTime now.
	"anEvent processTelemetry: aProcessTelemetry."
	self addEvent: anEvent.

	^ aResult
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetry >> reset [
	events removeAll
]

{ #category : #'api - telemetry' }
AsyncFutureThreadPoolTelemetry >> scheduled: anAsyncPendingFuturePromise worker: aWorker [
	self addEvent: (AsyncFutureThreadPoolTelemetryScheduledEvent new
		promise: anAsyncPendingFuturePromise
		worker: aWorker)
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetry >> setEvents: aCollectionOfEvents [
	events := aCollectionOfEvents
]
