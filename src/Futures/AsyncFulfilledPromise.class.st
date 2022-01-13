Class {
	#name : #AsyncFulfilledPromise,
	#superclass : #Object,
	#traits : 'TAsyncPromise',
	#classTraits : 'TAsyncPromise classTrait',
	#instVars : [
		'value'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'api - promise' }
AsyncFulfilledPromise >> asyncThen: onFulfilledBlock [
	<return: #TAsyncPromise>
	| aFutureValue |

	aFutureValue := [ (AsyncPromiseComputation new
		computation: onFulfilledBlock;
		isSynchronous: false)
			value: value ] asAsyncFuture.

	^ AsyncFuturePromise new future: aFutureValue
]

{ #category : #'api - promise' }
AsyncFulfilledPromise >> then: aFulfillmentBlock [
	<return: #TAsyncPromise>
	
	^ (AsyncPromiseComputation new
		computation: aFulfillmentBlock;
		isSynchronous: true)
			value: value
			ifSuccess: [ :aSuccessValue | AsyncFulfilledPromise new value: aSuccessValue ]
			ifError: [ :anError | AsyncRejectedPromise new error: anError ]
			ifPromise: [ :aPromise | aPromise ]
]

{ #category : #'api - promise' }
AsyncFulfilledPromise >> then: aFulfillmentBlock otherwise: aRejectionBlock [
	<return: #TAsyncPromise>

	^ self then: aFulfillmentBlock
]

{ #category : #'private - accessing' }
AsyncFulfilledPromise >> value [
	^ value
]

{ #category : #'private - accessing' }
AsyncFulfilledPromise >> value: anObject [
	AsyncPromiseComputation assertNotPromise: anObject.

	value := anObject
]
