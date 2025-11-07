"
I should be used sparingly only for critical calculations, e.g., to display critical tools that must work even when other tools (views) are blocked by a long computation.
"
Class {
	#name : #AsyncFutureExecutionConfiguration,
	#superclass : #Object,
	#instVars : [
		'priority',
		'group',
		'errorHandler',
		'maxAmountOfWorkers'
	],
	#classInstVars : [
		'defaultErrorHandler'
	],
	#category : #'Futures-Executor'
}

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> default [
	^ self new
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> defaultErrorHandler [
	^ defaultErrorHandler ifNil: [ AsyncNoneErrorHandler uniqueInstance ]
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> initialize [
	self normalExceptionHandlingByDefault
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> normalExceptionHandlingByDefault [
	"Goes through a normal mechanism of rejecting promises."

	defaultErrorHandler := AsyncNoneErrorHandler uniqueInstance
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration class >> passExceptionsByDefault [
	"Should only be used for debugging as it influences the normal handling of promises.
	Passes exceptions and raises a debugger rather than rejecting promises."
	defaultErrorHandler := AsyncPassExceptionHandler new
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

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> importantPriority [
	"I should be used carefully only for a critical tools, e.g., Monitor views."

	self priority: AsyncFutureExecutionImportantPriority uniqueInstance
]

{ #category : #initialization }
AsyncFutureExecutionConfiguration >> initialize [
	super initialize.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance.
	errorHandler := self class defaultErrorHandler.
	maxAmountOfWorkers := 1
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> lowPriority [
	self priority: AsyncFutureExecutionLowPriority uniqueInstance
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> maxAmountOfWorkers [
	^ maxAmountOfWorkers
]

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> maxAmountOfWorkers: aNumber [
	maxAmountOfWorkers := aNumber
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

{ #category : #accessing }
AsyncFutureExecutionConfiguration >> userBackgroundPriority [
	self priority: AsyncFutureExecutionUserBackgroundPriority uniqueInstance
]
