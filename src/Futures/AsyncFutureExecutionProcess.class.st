Class {
	#name : #AsyncFutureExecutionProcess,
	#superclass : #Object,
	#instVars : [
		'process',
		'worker'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionProcess >> objectOfInterest [
	^ self worker
]

{ #category : #accessing }
AsyncFutureExecutionProcess >> process [
	^ process at: 1
]

{ #category : #accessing }
AsyncFutureExecutionProcess >> process: aProcess [
	process := aProcess asWeakReference
]

{ #category : #accessing }
AsyncFutureExecutionProcess >> worker [

	^ worker
]

{ #category : #accessing }
AsyncFutureExecutionProcess >> worker: anObject [

	worker := anObject
]
