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

{ #category : #extensions }
AsyncFutureThreadPoolTelemetry >> gtOverviewListFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Overview';
		priority: 5;
		stencil: [
			| colors |
			colors := Dictionary new
				at: AsyncFutureThreadPoolTelemetryScheduledEvent
					put: (Color transparent);
				at: AsyncFutureThreadPoolTelemetryDoneEvent
					put: (Color transparent);
				yourself.
			
			GtPlotterHorizontalCompositeBarChartStencil new
				leftPadding: 20;
				labelWidth: 250;
				rowHeight: 20;
				barHeight: 17;
				withoutGridlines;
				withoutTickLabels;
				withDescriptionAsLabel;
				executions: self eventsByWorker;
				startTimeComputation: #startTime;
				endTimeComputation: #endTime;
				colorComputation: [ :each | colors at: each class ifAbsent: [ Color veryLightGray ] ];
				executionGeometryComputation: [ :each | BlRectangleGeometry new ];
				rowValuesComputation: #events;
				barStyleComputation: [ :anElement :anEvent |
					(anEvent isKindOf: AsyncFutureThreadPoolTelemetryPolledEvent)
						ifTrue: [
							| statusWeight pollTimeScale pollDurationScale |
							
							statusWeight := 1.
							
							anElement layout: BlFrameLayout new.
					
							anElement addChild: (BlElement new
								background: Color blue;
								constraintsDo: [ :c |
									c horizontal matchParent.
									c vertical matchParent.
									c frame vertical weight: statusWeight.
									c frame vertical alignBottom
								]).
							
							pollTimeScale := GtPlotterTimeScale new 
								domainFrom: anEvent startTime
								to: anEvent endTime.
						
							pollDurationScale := (GtPlotterDurationScale new
								domainFrom: 0 seconds
								to: anEvent duration).
							
							anEvent processTelemetry pauseEvents
								do: [ :eachPause |
									anElement addChild: (BlElement new
										background: (eachPause isWaitingOnSemaphore
											ifTrue: [ Color orange ]
											ifFalse: [ Color veryLightGray ]);
										constraintsDo: [ :c | 
											c vertical matchParent.
											c horizontal matchParent.
											c frame vertical weight: statusWeight.
											c frame vertical alignBottom.
											c frame horizontal
												weight: (pollDurationScale map: eachPause duration).
											c frame horizontal 
												alignLeftAt: (pollTimeScale 
													map: (eachPause startTime)) ])
								].
						].
				]
				
				 ];
		actionUpdateButton
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
