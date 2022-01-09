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
	self future: anAsyncFuture configuration: AsyncFutureExecutionConfiguration default
]

{ #category : #initialization }
AsyncFuturePromise >> future: anAsyncFuture configuration: anExecutionConfiguration [
	future := anAsyncFuture asAsyncFuture.
	(future await: anExecutionConfiguration)
		then: [ :aValue |
			aValue isAsyncPromise
				ifTrue: [ aValue asyncThen: [ :aPromiseValue | self fulfillWithValue: aPromiseValue ] ]
				ifFalse: [ self fulfillWithValue: aValue ].
			aValue ]
		"make sure that we do not return a promise from the otherwise: block"
		otherwise: [ :anError | self rejectWithError: anError. anError ]
]

{ #category : #'private - state' }
AsyncFuturePromise >> rejectWithError: anError [
	self rejectWithTransformedError: anError
]
