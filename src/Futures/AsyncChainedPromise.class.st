Class {
	#name : #AsyncChainedPromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'previousPromise',
		'fulfilledComputation',
		'rejectedComputation'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #'private - state' }
AsyncChainedPromise >> fulfillWithValue: aValue [
	AsyncPromiseComputation assertNotPromise: aValue.

	(AsyncPromiseComputation new
		computation: fulfilledComputation;
		isSynchronous: false)
			value: aValue
			ifSuccess: [ :aSuccessValue | self fulfillWithTransformedValue: aSuccessValue ]
			ifError: [ :anError | self rejectWithTransformedError: anError ]
			ifPromise: [ :aPromise |
				aPromise
					then: [ :aPromiseValue | self fulfillWithTransformedValue:  aPromiseValue ]
					otherwise: [ :anError | self rejectWithTransformedError: anError ] ]
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
AsyncChainedPromise >> previousPromise: anObject [

	previousPromise := anObject
]

{ #category : #'private - state' }
AsyncChainedPromise >> rejectWithError: anError [
	AsyncPromiseComputation assertNotPromise: anError.

	rejectedComputation
		ifNil: [ self rejectWithTransformedError: anError ]
		ifNotNil: [ :anErrorHandlingBlock |
			(AsyncPromiseComputation new
				computation: anErrorHandlingBlock;
				isSynchronous: false)
					value: anError
					ifSuccess: [ :aSuccessValue | self fulfillWithTransformedValue: aSuccessValue ]
					ifError: [ :aHandlerError | self rejectWithTransformedError: aHandlerError ]
					ifPromise: [ :aPromise |
						aPromise
							then: [ :aPromiseValue | self fulfillWithTransformedValue:  aPromiseValue ]
							otherwise: [ :aHandlerError | self rejectWithTransformedError: aHandlerError ] ] ]
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation [

	^ rejectedComputation
]

{ #category : #accessing }
AsyncChainedPromise >> rejectedComputation: anObject [

	rejectedComputation := anObject
]
