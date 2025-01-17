Class {
	#name : #AsyncFutureThreadPoolTelemetryByPromise,
	#superclass : #Object,
	#instVars : [
		'events',
		'startTime',
		'endTime',
		'promise'
	],
	#category : #'Futures-Executor - Telemetry'
}

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByPromise >> duration [
	^ self endTime - self startTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByPromise >> endTime [
	^ endTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByPromise >> events [
	^ events
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetryByPromise >> events: aCollectionOfEvents [
	events := aCollectionOfEvents sorted: [ :a :b | a startTime < b endTime ].
	startTime := events first startTime.
	endTime := events inject: events first endTime into: [ :anEndTime :each | anEndTime max: each endTime ].

	endTime > startTime
		ifFalse: [ endTime := startTime + 1 milliSecond ].
	
	promise := events first promise
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetryByPromise >> initialize [
	super initialize.
	
	events := #()
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByPromise >> promise [
	^ promise
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryByPromise >> startTime [
	^ startTime
]
