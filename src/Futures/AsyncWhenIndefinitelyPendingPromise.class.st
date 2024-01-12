Class {
	#name : #AsyncWhenIndefinitelyPendingPromise,
	#superclass : #AsyncDeferredPromise,
	#instVars : [
		'callback'
	],
	#category : #'Futures-Base - Promises'
}

{ #category : #accessing }
AsyncWhenIndefinitelyPendingPromise >> callback [
	^ callback
]

{ #category : #accessing }
AsyncWhenIndefinitelyPendingPromise >> callback: anObject [
	callback := anObject
]

{ #category : #'private - state' }
AsyncWhenIndefinitelyPendingPromise >> fulfillWithValue: aValue [
	
]

{ #category : #'accessing - utils' }
AsyncWhenIndefinitelyPendingPromise >> notifyPotentiallyIndefinitelyPending [
	"Is sent by the futures worker when promise switches to the indefinitely pending state.
	Only promises that are derived from futures can be inidefinitely pending"
	
	callback value
]

{ #category : #'private - state' }
AsyncWhenIndefinitelyPendingPromise >> rejectWithError: anError [
	
]
