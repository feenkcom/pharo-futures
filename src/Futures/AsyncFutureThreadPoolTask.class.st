Class {
	#name : #AsyncFutureThreadPoolTask,
	#superclass : #Object,
	#instVars : [
		'future',
		'result'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #accessing }
AsyncFutureThreadPoolTask >> future [

	^ future
]

{ #category : #accessing }
AsyncFutureThreadPoolTask >> future: anObject [

	future := anObject
]

{ #category : #accessing }
AsyncFutureThreadPoolTask >> result [

	^ result
]

{ #category : #accessing }
AsyncFutureThreadPoolTask >> result: anObject [

	result := anObject
]
