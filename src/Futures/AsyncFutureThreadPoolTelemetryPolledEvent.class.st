Class {
	#name : #AsyncFutureThreadPoolTelemetryPolledEvent,
	#superclass : #AsyncFutureThreadPoolTelemetryEvent,
	#instVars : [
		'endTime',
		'processTelemetry'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> durationOfPauses [
	^ processTelemetry pauseEvents inject: 0 seconds into: [ :aSum :eachPause | aSum + eachPause duration ]
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> durationOfWork [
	^ self duration - self durationOfPauses
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> endTime [
	^ endTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> endTime: anObject [

	endTime := anObject
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> gtInfoFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Info';
		priority: 5;
		object: [ {
			'Total duration' -> (self duration gtPreciseHumanReadableString).
			'Pause duration' -> (self durationOfPauses gtPreciseHumanReadableString).
			'Work duration' -> (self durationOfWork gtPreciseHumanReadableString).
			'Efficiency' -> (((self workEfficiency * 100.0) printShowingDecimalPlaces: 2), '%').
			'Timestamp' -> (self startTime).
			'Promise' -> promise
		} asOrderedDictionary ];
		view: #gtItemsFor:
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> gtProcessPausesForFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Process pauses';
		priority: 7;
		object: [ processTelemetry ];
		view: #gtPauseEventsFor:
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> gtProcessSignalsForFor: aView [
	<gtView>
	
	^ aView forward
		title: 'Process signals';
		priority: 9;
		object: [ processTelemetry ];
		view: #gtSignalsFor:
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> gtTimelineFor: aView [
	<gtView>
	^ aView explicit
		title: 'Timeline';
		priority: 5;
		stencil: [ | anElement statusWeight pollTimeScale pollDurationScale |

			statusWeight := 1.
			
			anElement := BlElement new.
			anElement layout: BlFrameLayout new.
			anElement constraintsDo: [ :c | 
				c horizontal matchParent.
				c vertical exact: 50 ].

			anElement
				addChild: (BlElement new
						background: Color blue;
						constraintsDo: [ :c | 
							c horizontal matchParent.
							c vertical matchParent.
							c frame vertical weight: statusWeight.
							c frame vertical alignBottom ]).

			pollTimeScale := GtPlotterTimeScale new
					domainFrom: self startTime
					to: self endTime.

			pollDurationScale := GtPlotterDurationScale new
					domainFrom: 0 seconds
					to: self duration.

			self processTelemetry pauseEvents
				do: [ :eachPause | 
					anElement
						addChild: (BlElement new
								background: (eachPause isWaitingOnSemaphore
											ifTrue: [ Color orange ]
											ifFalse: [ Color veryLightGray ]);
								constraintsDo: [ :c | 
									c vertical matchParent.
									c horizontal matchParent.
									c frame vertical weight: statusWeight.
									c frame vertical alignBottom.
									c frame horizontal weight: (pollDurationScale map: eachPause duration).
									c frame horizontal
										alignLeftAt: (pollTimeScale map: eachPause startTime) ]) ].

			anElement ]
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> processTelemetry [
	^ processTelemetry
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> processTelemetry: anObject [
	processTelemetry := anObject
]

{ #category : #'as yet unclassified' }
AsyncFutureThreadPoolTelemetryPolledEvent >> workEfficiency [
	^ self durationOfWork / self durationOfPauses
]
