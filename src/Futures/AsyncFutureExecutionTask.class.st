Class {
	#name : #AsyncFutureExecutionTask,
	#superclass : #Object,
	#instVars : [
		'future',
		'result'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionTask >> future [

	^ future
]

{ #category : #accessing }
AsyncFutureExecutionTask >> future: anObject [

	future := anObject
]

{ #category : #accessing }
AsyncFutureExecutionTask >> result [

	^ result
]

{ #category : #accessing }
AsyncFutureExecutionTask >> result: anObject [

	result := anObject
]
