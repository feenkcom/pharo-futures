Class {
	#name : #AsyncFutureThreadPoolWaker,
	#superclass : #Object,
	#traits : 'TAsyncFutureExecutionWaker',
	#classTraits : 'TAsyncFutureExecutionWaker classTrait',
	#instVars : [
		'worker',
		'task'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #'private - accessing' }
AsyncFutureThreadPoolWaker >> task [
	^ task
]

{ #category : #'private - accessing' }
AsyncFutureThreadPoolWaker >> task: anObject [

	task := anObject
]

{ #category : #'api - execution' }
AsyncFutureThreadPoolWaker >> wakeUp [
	worker wakeUp: task
]

{ #category : #'private - accessing' }
AsyncFutureThreadPoolWaker >> worker: anObject [
	worker := anObject
]
