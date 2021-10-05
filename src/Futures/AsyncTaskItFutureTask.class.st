Class {
	#name : #AsyncTaskItFutureTask,
	#superclass : #TKTTask,
	#instVars : [
		'asyncFuture'
	],
	#category : #'Futures-Executor'
}

{ #category : #'instance creation' }
AsyncTaskItFutureTask class >> forAsyncFuture: aTAsyncFuture [
	^ (self new asyncFuture: aTAsyncFuture) future: self runner
]

{ #category : #accessing }
AsyncTaskItFutureTask class >> runner [
	| aRunner |
	
	aRunner := TKTConfiguration serviceManager services
		detect: [ :any | (any isKindOf: TKTWatchDog) and: [
			any pool 
				ifNotNil: [ :aPool | aPool name = 'Futures' ]
				ifNil: [ false ] ] ]
		ifFound: [ :aService | aService pool ]
		ifNone: [
			| aPoolClass |
			
			aPoolClass := Object environment
				at: #BlTktCommonQueueWorkerPool
				ifAbsent: [ TKTConfiguration runner class ].

			aPoolClass new
				name: 'Futures';
				processPriority: 30;
				poolMaxSize: 10;
				start ].

	^ aRunner
]

{ #category : #accessing }
AsyncTaskItFutureTask >> asyncFuture: anAsyncFuture [
	asyncFuture := anAsyncFuture
]

{ #category : #accessing }
AsyncTaskItFutureTask >> entryIdentifier [
	"Answer the queue entry identifier of the receiver for task scheduling.
	Defer to my command."

	^ nil
]

{ #category : #accessing }
AsyncTaskItFutureTask >> entryPriority [
	^ 1
]

{ #category : #executing }
AsyncTaskItFutureTask >> futureTaskExecutionFor: aRunner [
	^ self configureTaskExecution: AsyncFutureExecution new with: aRunner
]

{ #category : #accessing }
AsyncTaskItFutureTask >> name [
	<return: #String>

	^ asyncFuture class
]

{ #category : #executing }
AsyncTaskItFutureTask >> scheduleTaskExecutionFor: aRunner [
	^ self configureTaskExecution: AsyncFutureExecution new with: aRunner
]

{ #category : #executing }
AsyncTaskItFutureTask >> value [
	self
		assert: [ asyncFuture notNil ]
		description: [ 'Future must be initialized before using it' ].

	^ asyncFuture poll: self
]
