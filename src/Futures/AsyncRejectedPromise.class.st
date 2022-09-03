Class {
	#name : #AsyncRejectedPromise,
	#superclass : #Object,
	#traits : 'TAsyncPromise',
	#classTraits : 'TAsyncPromise classTrait',
	#instVars : [
		'error'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'api - promise' }
AsyncRejectedPromise >> asyncThen: onFulfilledBlock [
	<return: #TAsyncPromise>

	^ self
]

{ #category : #'private - accessing' }
AsyncRejectedPromise >> error [
	^ error
]

{ #category : #'private - accessing' }
AsyncRejectedPromise >> error: anError [
	error := anError signalContext ifNil: [ anError ]
		ifNotNil: [ anError copy freeze ]
]

{ #category : #'api - promise' }
AsyncRejectedPromise >> then: aFulfillmentBlock [
	<return: #TAsyncPromise>

	^ self
]

{ #category : #'api - promise' }
AsyncRejectedPromise >> then: onFulfilledBlock otherwise: onRejectedBlock [
	<return: #TAsyncPromise>
	
	^ (AsyncPromiseComputation new
		computation: onRejectedBlock;
		isSynchronous: true)
			value: error
			ifSuccess: [ :aSuccessValue | AsyncFulfilledPromise new value: aSuccessValue ]
			ifError: [ :anError | AsyncRejectedPromise new error: anError ]
			ifPromise: [ :aPromise | aPromise ]
]
