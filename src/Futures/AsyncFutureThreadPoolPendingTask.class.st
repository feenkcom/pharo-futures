Class {
	#name : #AsyncFutureThreadPoolPendingTask,
	#superclass : #Object,
	#instVars : [
		'task',
		'sinceTime'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #printing }
AsyncFutureThreadPoolPendingTask >> printOn: aStream [

	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Pending ';
		print: task.
	aStream
		nextPutAll: ' since ';
		nextPutAll: (DateAndTime now - sinceTime) humanReadablePrintString
]

{ #category : #accessing }
AsyncFutureThreadPoolPendingTask >> sinceTime [

	^ sinceTime
]

{ #category : #accessing }
AsyncFutureThreadPoolPendingTask >> task [

	^ task
]

{ #category : #initialization }
AsyncFutureThreadPoolPendingTask >> task: anAsyncFutureThreadPoolTask [
	task := anAsyncFutureThreadPoolTask.
	sinceTime := DateAndTime now
]
