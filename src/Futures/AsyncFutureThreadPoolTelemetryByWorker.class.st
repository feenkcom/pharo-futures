Class {
	#name : #AsyncFutureThreadPoolTelemetryByWorker,
	#superclass : #Object,
	#instVars : [
		'events',
		'startTime',
		'endTime',
		'worker'
	],
	#category : #'Futures-Executor - Telemetry'
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
