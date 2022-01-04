Class {
	#name : #AsyncFutureThreadPoolQueue,
	#superclass : #Object,
	#instVars : [
		'queue'
	],
	#category : #'Futures-Executor - Thread Pool'
}

{ #category : #initialization }
AsyncFutureThreadPoolQueue >> initialize [
	super initialize.

	queue := SharedQueue new
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> pop [
	^ queue nextOrNil
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> pop: anObject [
	<return: #Object or: nil>

	^ queue findFirst: [ :each | each == anObject ]
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> popAll [
	"Remove all items from the queue"

	^ queue nextAllOrEmpty
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> popAndWait [
	^ queue next
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> pushBack: anObject [
	queue nextPut: anObject
]

{ #category : #accessing }
AsyncFutureThreadPoolQueue >> pushBackAll: aCollection [
	aCollection do: [ :each | queue nextPut: each ]
]
