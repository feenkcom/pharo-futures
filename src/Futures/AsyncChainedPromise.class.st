Class {
	#name : #AsyncChainedPromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'fulfilledComputation',
		'rejectedComputation'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'private - state' }
AsyncChainedPromise >> fulfillWithValue: aValue [
	| aTransformedValue theFulfillmentPromises |

	aTransformedValue := (AsyncPromiseComputation new
		computation: fulfilledComputation;
		isSynchronous: false)
			value: aValue.

	mutex critical: [
		state := (AsyncFulfilledPromiseState new value: aTransformedValue).
		theFulfillmentPromises := whenResolvedPromises.
		whenResolvedPromises := OrderedCollection new ].

	theFulfillmentPromises do: [ :eachPromise | eachPromise fulfillWithValue: aTransformedValue ]
]

{ #category : #accessing }
AsyncChainedPromise >> fulfilledComputation [

	^ fulfilledComputation
]

{ #category : #accessing }
AsyncChainedPromise >> fulfilledComputation: anObject [

	fulfilledComputation := anObject
]

{ #category : #'private - state' }
AsyncChainedPromise >> rejectWithError: anError [

	rejectedComputation
		ifNil: [
			| theRejectionPromises |
			mutex critical: [
				state := (AsyncRejectedPromiseState new error: anError).
				theRejectionPromises := whenRejectedPromises.
				whenRejectedPromises := OrderedCollection new ].
			theRejectionPromises do: [ :eachPromise | eachPromise rejectWithError: anError ] ]
		ifNotNil: [ :anErrorHandlingBlock |
			| aTransformedValue theFulfillmentPromises |

			aTransformedValue := (AsyncPromiseComputation new
				computation: anErrorHandlingBlock;
				isSynchronous: false)
					value: anError.

			mutex critical: [
				state := (AsyncFulfilledPromiseState new value: aTransformedValue).
				theFulfillmentPromises := whenResolvedPromises.
				whenResolvedPromises := OrderedCollection new ].

			theFulfillmentPromises do: [ :eachPromise | eachPromise fulfillWithValue: aTransformedValue ] ]
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation [

	^ rejectedComputation
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation: anObject [

	rejectedComputation := anObject
]
