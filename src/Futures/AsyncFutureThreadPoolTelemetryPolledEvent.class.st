Class {
	#name : #AsyncFutureThreadPoolTelemetryPolledEvent,
	#superclass : #AsyncFutureThreadPoolTelemetryEvent,
	#instVars : [
		'endTime'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> endTime [
	^ endTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryPolledEvent >> endTime: anObject [

	endTime := anObject
]
