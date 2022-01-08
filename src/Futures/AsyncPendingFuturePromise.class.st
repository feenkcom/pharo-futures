Class {
	#name : #AsyncPendingFuturePromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'future',
		'group',
		'priority'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'private - state' }
AsyncPendingFuturePromise >> fulfillWithValue: aValue [
	self fulfillWithTransformedValue: aValue
]

{ #category : #accessing }
AsyncPendingFuturePromise >> future [

	^ future
]

{ #category : #accessing }
AsyncPendingFuturePromise >> future: anObject [

	future := anObject
]

{ #category : #accessing }
AsyncPendingFuturePromise >> group [

	^ group
]

{ #category : #accessing }
AsyncPendingFuturePromise >> group: anObject [

	group := anObject
]

{ #category : #initialization }
AsyncPendingFuturePromise >> initialize [
	super initialize.

	group := AsyncFutureExecutionUnspecifiedGroup uniqueInstance.
	priority := AsyncFutureExecutionDefaultPriority uniqueInstance
]

{ #category : #printing }
AsyncPendingFuturePromise >> printOn: aStream [
	"Append a sequence of characters to aStream that identify the receiver."
	aStream
		nextPutAll: 'Pending future promise';
		nextPutAll: ' state: ';
		print: state.
	aStream
		nextPutAll: ' future: ';
		print: future
]

{ #category : #accessing }
AsyncPendingFuturePromise >> priority [
	<return: #AsyncFutureExecutionPriority>

	^ priority
]

{ #category : #accessing }
AsyncPendingFuturePromise >> priority: anAsyncFutureExecutionPriority [
	priority := anAsyncFutureExecutionPriority
]

{ #category : #'private - state' }
AsyncPendingFuturePromise >> rejectWithError: anError [
	self rejectWithTransformedError: anError
]
