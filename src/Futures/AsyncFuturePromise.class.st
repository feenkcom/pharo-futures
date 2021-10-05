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
	| theFulfillmentPromises |

	mutex critical: [
		state := (AsyncFulfilledPromiseState new value: aValue).
		theFulfillmentPromises := whenResolvedPromises.
		whenResolvedPromises := OrderedCollection new ].

	theFulfillmentPromises do: [ :eachPromise | eachPromise fulfillWithValue: aValue ]
]

{ #category : #initialization }
AsyncFuturePromise >> future: anAsyncFuture [
	future := anAsyncFuture asAsyncFuture.
	future await
		onSuccessDo: [ :aValue | self fulfillWithValue: aValue ];
		onFailureDo: [ :anError | anError freeze. self rejectWithError: anError ]
]

{ #category : #'private - state' }
AsyncFuturePromise >> rejectWithError: anError [
	| theRejectionPromises |

	mutex critical: [
		state := (AsyncRejectedPromiseState new error: anError).
		theRejectionPromises := whenRejectedPromises.
		whenRejectedPromises := OrderedCollection new ].

	theRejectionPromises do: [ :eachPromise | eachPromise rejectWithError: anError ]
]
