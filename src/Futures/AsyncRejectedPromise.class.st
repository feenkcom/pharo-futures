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

{ #category : #accessing }
AsyncRejectedPromise >> error: anError [
	error := anError
]

{ #category : #'api - promise' }
AsyncRejectedPromise >> then: aFulfillmentBlock [
	<return: #TAsyncPromise>

	^ self
]

{ #category : #'api - promise' }
AsyncRejectedPromise >> then: onFulfilledBlock otherwise: onRejectedBlock [
	<return: #TAsyncPromise>
	| aTransformedValue |

	aTransformedValue := (AsyncPromiseComputation new
		computation: onRejectedBlock;
		isSynchronous: true)
			value: error.

	^ AsyncFulfilledPromise new value: aTransformedValue
]
