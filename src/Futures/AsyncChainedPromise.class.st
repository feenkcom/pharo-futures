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
	| aTransformedValue  |

	AsyncPromiseComputation assertNotPromise: aValue.

	aTransformedValue := (AsyncPromiseComputation new
		computation: fulfilledComputation;
		isSynchronous: false)
			value: aValue.

	aTransformedValue isAsyncPromise
		ifTrue: [
			aTransformedValue
				then: [ :aPromiseValue | self fulfillWithTransformedValue:  aPromiseValue ]
				otherwise: [ :anError | self rejectWithTransformedError: anError ] ]
		ifFalse: [ self fulfillWithTransformedValue:  aTransformedValue ]
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
		ifNil: [ self rejectWithTransformedError: anError ]
		ifNotNil: [ :anErrorHandlingBlock |
			| aTransformedValue |

			aTransformedValue := (AsyncPromiseComputation new
				computation: anErrorHandlingBlock;
				isSynchronous: false)
					value: anError.

			self fulfillWithTransformedValue: aTransformedValue ]
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation [

	^ rejectedComputation
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation: anObject [

	rejectedComputation := anObject
]
