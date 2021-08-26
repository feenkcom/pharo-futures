Class {
	#name : 'AsyncTaskItFutureTask',
	#superclass : 'TKTTask',
	#instVars : [
		'future'
	],
	#category : 'Futures-Executor'
}

{ #category : 'accessing' }
AsyncTaskItFutureTask >> entryIdentifier [
	"Answer the queue entry identifier of the receiver for task scheduling.
	Defer to my command."

	^ nil
]

{ #category : 'accessing' }
AsyncTaskItFutureTask >> entryPriority [
	^ 1
]

{ #category : 'accessing' }
AsyncTaskItFutureTask >> forFuture: aGtFuture [
	future := aGtFuture
]

{ #category : 'executing' }
AsyncTaskItFutureTask >> futureTaskExecutionFor: aRunner [
	^ self configureTaskExecution: AsyncFutureExecution new with: aRunner
]

{ #category : 'accessing' }
AsyncTaskItFutureTask >> name [
	<return: #String>

	^ future class
]

{ #category : 'executing' }
AsyncTaskItFutureTask >> scheduleTaskExecutionFor: aRunner [
	^ self configureTaskExecution: AsyncFutureExecution new with: aRunner
]

{ #category : 'executing' }
AsyncTaskItFutureTask >> value [
	self
		assert: [ future notNil ]
		description: [ 'Future must be initialized before using it' ].

	^ future poll: self
]
