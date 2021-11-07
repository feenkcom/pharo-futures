Class {
	#name : #AsyncFuturePromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'future'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'private - state' }
AsyncFuturePromise >> fulfillWithValue: aValue [
	self fulfillWithTransformedValue: aValue
]

{ #category : #initialization }
AsyncFuturePromise >> future: anAsyncFuture [
	future := anAsyncFuture asAsyncFuture.
	future await
		onSuccessDo: [ :aValue |
			aValue isAsyncPromise
				ifTrue: [ aValue asyncThen: [ :aPromiseValue | self fulfillWithValue: aPromiseValue ] ]
				ifFalse: [ self fulfillWithValue: aValue ] ];
		onFailureDo: [ :anError | self rejectWithError: anError ]
]

{ #category : #'private - state' }
AsyncFuturePromise >> rejectWithError: anError [
	self rejectWithTransformedError: anError
]
