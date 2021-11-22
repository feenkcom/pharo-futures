Class {
	#name : #AsyncPendingPromise,
	#superclass : #AsyncDeferredPromise,
	#category : #'Futures-Base - Promises'
}

{ #category : #'private - state' }
AsyncPendingPromise >> fulfillWithValue: aValue [
	aValue isAsyncPromise
		ifTrue: [ aValue asyncThen: [ :aPromiseValue | self fulfillWithValue: aPromiseValue ] ]
		ifFalse: [ self fulfillWithTransformedValue: aValue ]
]

{ #category : #'private - state' }
AsyncPendingPromise >> rejectWithError: anError [
	self rejectWithTransformedError: anError
]
