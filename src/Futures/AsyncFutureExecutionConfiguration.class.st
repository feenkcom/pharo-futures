Class {
	#name : #AsyncFutureExecutionConfiguration,
	#superclass : #Object,
	#instVars : [
		'priority',
		'group',
		'errorHandler'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> default [
	^ self new
]

{ #category : #comparing }
AsyncFutureExecutionConfiguration >> = anObject [

	"Answer whether the receiver and anObject represent the same object."

	self == anObject ifTrue: [ ^ true ].
	self class = anObject class ifFalse: [ ^ false ].
	^ priority = anObject priority and: [ group = anObject group ]
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> customGroup: anObject [
	self group: (AsyncFutureExecutionValueGroup new value: anObject)
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> defaultPriority [
	self priority: AsyncFutureExecutionDefaultPriority uniqueInstance
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> errorHandler [

	^ errorHandler
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> errorHandler: anObject [

	errorHandler := anObject
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> group [
	<return: #AsyncFutureExecutionGroup>

	^ group
]

{ #category : #initialization }
AsyncFutureExecutionConfiguration >> group: anAsyncFutureExecutionGroup [
	group := anAsyncFutureExecutionGroup
]

{ #category : #comparing }
AsyncFutureExecutionConfiguration >> hash [

	"Answer an integer value that is related to the identity of the receiver."

	^ priority hash bitXor: group hash
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> highPriority [
	self priority: AsyncFutureExecutionHighPriority uniqueInstance
]

{ #category : #initialization }
AsyncFutureExecutionConfiguration >> initialize [
	super initialize.
	
	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.
	errorHandler := AsyncNoneErrorHandler uniqueInstance
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> lowPriority [
	self priority: AsyncFutureExecutionLowPriority uniqueInstance
]

{ #category : #printing }
AsyncFutureExecutionConfiguration >> printOn: aStream [

	"Append a sequence of characters to aStream that identify the receiver."

	super printOn: aStream.
	aStream
		nextPutAll: ' group: ';
		print: group.
	aStream
		nextPutAll: ' priority: ';
		print: priority
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> priority [
	<return: #AsyncFutureExecutionPriority>

	^ priority
]

{ #category : #initialization }
AsyncFutureExecutionConfiguration >> priority: anAsyncFutureExecutionPriority [
	priority := anAsyncFutureExecutionPriority
]
