Class {
	#name : #AsyncDeferredPromise,
	#superclass : #Object,
	#traits : 'TAsyncPromise',
	#classTraits : 'TAsyncPromise classTrait',
	#instVars : [
		'state',
		'mutex',
		'whenResolvedPromises',
		'whenRejectedPromises'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #testing }
AsyncDeferredPromise class >> isAbstract [
	^ self = AsyncDeferredPromise
]

{ #category : #'api - promise' }
AsyncDeferredPromise >> asyncThen: onFulfilledBlock [
	mutex critical: [
		state isPending
			ifTrue: [
				| aResolvedPromise |
				
				aResolvedPromise := AsyncChainedPromise new
					fulfilledComputation: onFulfilledBlock.

				whenResolvedPromises add: aResolvedPromise.
				^ aResolvedPromise ] ].

	state isFulfilled
		ifTrue: [
			^ AsyncFulfilledPromise new
				value: state value;
				asyncThen: onFulfilledBlock ].
		
	state isRejected
		ifTrue: [ ^ AsyncRejectedPromise new error: state error ].

	^ self error: ('Unexpected state: {1}' format: { state })
]

{ #category : #'private - state' }
AsyncDeferredPromise >> fulfillWithValue: aValue [
	self subclassResponsibility
]

{ #category : #initialization }
AsyncDeferredPromise >> initialize [
	super initialize.
	
	state := AsyncPendingPromiseState new.
	mutex := Monitor new.
	whenResolvedPromises := OrderedCollection new.
	whenRejectedPromises := OrderedCollection new.
]

{ #category : #testing }
AsyncDeferredPromise >> isPending [
	^ state isPending
]

{ #category : #testing }
AsyncDeferredPromise >> isSettled [
	^ state isPending not
]

{ #category : #'private - state' }
AsyncDeferredPromise >> rejectWithError: anError [
	self subclassResponsibility
]

{ #category : #'api - promise' }
AsyncDeferredPromise >> then: onFulfilledBlock [
	mutex critical: [
		state isPending
			ifTrue: [
				| aResolvedPromise |
				
				aResolvedPromise := AsyncChainedPromise new
					fulfilledComputation: onFulfilledBlock.

				whenResolvedPromises add: aResolvedPromise.
				^ aResolvedPromise ] ].

	state isFulfilled
		ifTrue: [
			^ AsyncFulfilledPromise new
				value: state value;
				then: onFulfilledBlock ].
		
	state isRejected
		ifTrue: [ ^ AsyncRejectedPromise new error: state error ].
		
	^ self error: ('Unexpected state: {1}' format: { state })
]

{ #category : #'api - promise' }
AsyncDeferredPromise >> then: onFulfilledBlock otherwise: onRejectedBlock [
	<return: #TAsyncPromise>
	
	mutex critical: [
		state isPending
			ifTrue: [
				| aDeferredPromise |

				aDeferredPromise := AsyncChainedPromise new
					fulfilledComputation: onFulfilledBlock;
					rejectedComputation: onRejectedBlock.

				whenResolvedPromises add: aDeferredPromise.
				whenRejectedPromises add: aDeferredPromise.
				^ aDeferredPromise ] ].

	state isFulfilled
		ifTrue: [
			| aTransformedValue |
			aTransformedValue := (AsyncPromiseComputation new
				computation: onFulfilledBlock;
				isSynchronous: true)
					value: state value.

			^ AsyncFulfilledPromise new value: aTransformedValue ].

	state isRejected
		ifTrue: [
			| aTransformedValue |
			aTransformedValue := (AsyncPromiseComputation new
				computation: onRejectedBlock;
				isSynchronous: true)
					value: state error.
			^ AsyncRejectedPromise new error: aTransformedValue ].

	^ self error: ('Unexpected state: {1}' format: { state })
]
