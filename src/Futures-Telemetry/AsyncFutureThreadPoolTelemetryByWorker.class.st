Class {
	#name : #AsyncFutureThreadPoolTelemetryByWorker,
	#superclass : #Object,
	#instVars : [
		'events',
		'startTime',
		'endTime',
		'worker'
	],
	#category : #'Futures-Telemetry-Telemetry'
}

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryByWorker >> description [
	^ String streamContents: [ :s |
		s
			nextPutAll: (worker group ifNotNil: #label ifNil: [ 'undefined group' ]);
			nextPutAll: ' ('.
		worker priority gtDisplayOn: s.
		s nextPutAll: ')' ]
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByWorker >> duration [
	^ self endTime - self startTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByWorker >> endTime [
	^ endTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByWorker >> events [
	^ events
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetryByWorker >> events: aCollectionOfEvents [
	events := aCollectionOfEvents sorted: [ :a :b | a startTime < b endTime ].
	startTime := events first startTime.
	endTime := events inject: events first endTime into: [ :anEndTime :each | anEndTime max: each endTime ].

	endTime > startTime
		ifFalse: [ endTime := startTime + 1 milliSecond ].
	
	worker := events first worker
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByWorker >> gtTimelineFor: aView [
	<gtView>
	
	^ aView explicit
		title: 'Timeline';
		priority: 5;
		stencil: [
			| timeScale colors |
			
			colors := Dictionary new
				at: AsyncFutureThreadPoolTelemetryScheduledEvent
					put: Color transparent;
				at: AsyncFutureThreadPoolTelemetryDoneEvent
					put: Color transparent;
				yourself.
			
			timeScale := GtPlotterTimeScale new 
				domainFrom: self startTime
				to: self endTime.
		
			GtPlotterHorizontalValueBarsElement new
				height: 30;
				scale: (GtPlotterDurationScale new
					domainFrom: 0 seconds
					to: self duration);
				scaleData: [ :each | each duration ];
				valueStyle: [ :anElement :aGtScaleContext |
					| anEvent |
					anEvent := aGtScaleContext originalValue.
					
					(anEvent isKindOf: AsyncFutureThreadPoolTelemetryPolledEvent)
						ifTrue: [
							| statusWeight pollTimeScale pollDurationScale |
							
							statusWeight := 1.
							
							anElement layout: BlFrameLayout new.
					
							anElement addChild: (BlElement new
								background: (Color blue);
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
					
					anElement background: (colors at: anEvent class ifAbsent: [ Color random paler paler  ]).
					anElement
						when: BlClickEvent
						do: [ :aClickEvent |
							aClickEvent consumed: true.
							aClickEvent currentTarget phlow spawnObject: anEvent ].
						
					anElement constraintsDo: [ :c | 
						c frame horizontal 
							alignLeftAt: (timeScale 
								map: (anEvent startTime)) ] ];
				values: events
		]
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetryByWorker >> initialize [
	super initialize.
	
	events := #()
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByWorker >> startTime [
	^ startTime
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryByWorker >> worker [
	^ worker
]
