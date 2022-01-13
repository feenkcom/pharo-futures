Class {
	#name : #AsyncFutureExecutionContext,
	#superclass : #Object,
	#instVars : [
		'waker'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionContext >> waker [
	<return: #TAsyncFutureExecutionWaker>

	^ waker
]

{ #category : #accessing }
AsyncFutureExecutionContext >> waker: aTAsyncFutureExecutionWaker [
	waker := aTAsyncFutureExecutionWaker
]
