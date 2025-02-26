Extension { #name : #AsyncFutureThreadPoolWorker }

{ #category : #'*Futures-Telemetry' }
AsyncFutureThreadPoolWorker >> gtTelemetryEventsFor: aView [
	<gtView>

	self
		telemetryDo: #yourself
		ifNone: [ ^ aView empty ].

	^ aView list
		title: 'Telemetry events';
		priority: 13;
		items: [ self telemetryDo: [ :aTelemetry | aTelemetry eventsForWorker: self ] ifNone: [ #() ] ]
]

{ #category : #'*Futures-Telemetry' }
AsyncFutureThreadPoolWorker >> gtTelemetryTimelineFor: aView [
	<gtView>

	self
		telemetryDo: #yourself
		ifNone: [ ^ aView empty ].

	^ aView explicit
		title: 'Telemetry timeline';
		priority: 14;
		stencil: [ 
			| allEvents eventsByPromise colors |
			
			allEvents := self telemetryDo: [ :aTelemetry | aTelemetry eventsForWorker: self ] ifNone: [ #() ].
			eventsByPromise := (allEvents groupedBy: [ :eachEvent | eachEvent promise ]) values
				collect: [ :eachArray | AsyncFutureThreadPoolTelemetryByPromise new events: eachArray ].
				
			colors := Dictionary new
				at: AsyncFutureThreadPoolTelemetryPolledEvent
					put: (Color gray alpha: 0.25);
				at: AsyncFutureThreadPoolTelemetryScheduledEvent
					put: ((Color r: 92 g: 204 b: 231 range: 255) alpha: 0.2);
				at: AsyncFutureThreadPoolTelemetryDoneEvent
					put: (Color transparent);
				yourself.
			
			GtPlotterHorizontalCompositeBarChartStencil new
				leftPadding: 20;
				labelWidth: 100;
				rowHeight: 15;
				executions: eventsByPromise;
				rowValuesComputation: #events;
				startTimeComputation: #startTime;
				endTimeComputation: #endTime;
				colorComputation: [ :each | colors at: each class ifAbsent: [ Color red alpha: 0.2 ] ];
				rowLabelComputation: [ :each | each promise identityHash ] ]
]

{ #category : #'*Futures-Telemetry' }
AsyncFutureThreadPoolWorker >> timelineOfRecentFutures [
	^ futuresCounter
		ifNil: [ #() ]
		ifNotNil: [ futuresCounter pingsTimeline ]
]
