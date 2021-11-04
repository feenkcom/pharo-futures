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

{ #category : #testing }
AsyncFulfilledPromise >> isAsyncPromise [
	^ true
]

{ #category : #'api - promise' }
AsyncFulfilledPromise >> then: onFulfilledBlock [
	<return: #TAsyncPromise>
	| aTransformedValue |

	aTransformedValue := (AsyncPromiseComputation new
		computation: onFulfilledBlock;
		isSynchronous: true)
			value: value.

	^ aTransformedValue isAsyncPromise
		ifTrue: [ aTransformedValue ]
		ifFalse: [ AsyncFulfilledPromise new value: aTransformedValue ]
]

{ #category : #'api - promise' }
AsyncFulfilledPromise >> then: aFulfillmentBlock otherwise: aRejectionBlock [
	<return: #TAsyncPromise>

	^ self then: aFulfillmentBlock
]

{ #category : #initialization }
AsyncFulfilledPromise >> value: anObject [
	AsyncPromiseComputation assertNotPromise: anObject.

	value := anObject
]
