Class {
	#name : #AsyncFutureThreadPoolTelemetryEvent,
	#superclass : #Object,
	#instVars : [
		'worker',
		'promise',
		'timestamp'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> duration [
	^ self endTime - self startTime
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> endTime [
	^ self timestamp + 1 milliSecond
]

{ #category : #initialization }
AsyncFutureThreadPoolTelemetryEvent >> initialize [
	super initialize.
	
	timestamp := DateAndTime now
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> promise [

	^ promise
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> promise: aPromise worker: aWorker [

	promise := aPromise.
	worker := aWorker
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> startTime [
	^ self timestamp
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> timestamp [

	^ timestamp
]

{ #category : #accessing }
AsyncFutureThreadPoolTelemetryEvent >> worker [

	^ worker
]
