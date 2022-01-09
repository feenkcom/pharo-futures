Class {
	#name : #AsyncDeferredPromise,
	#superclass : #Object,
	#traits : 'TAsyncPromise',
	#classTraits : 'TAsyncPromise classTrait',
	#instVars : [
		'mutex',
		'state',
		'chainedPromises'
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
					previousPromise: self;
					fulfilledComputation: onFulfilledBlock.

				chainedPromises add: aResolvedPromise.
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
AsyncDeferredPromise >> fulfillWithTransformedValue: anObject [
	| theFulfillmentPromises |
	
	AsyncPromiseComputation assertNotPromise: anObject.

	mutex critical: [
		self
			assert: [ state isPending ]
			description: [ 'Promise must be pending, but was ', state printString ].
		state := (AsyncFulfilledPromiseState new value: anObject).
		theFulfillmentPromises := chainedPromises.
		chainedPromises := self newChainedPromises ].

	theFulfillmentPromises do: [ :eachPromise | eachPromise fulfillWithValue: anObject ]
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
	chainedPromises := self newChainedPromises
]

{ #category : #testing }
AsyncDeferredPromise >> isFulfilled [
	^ state isFulfilled
]

{ #category : #testing }
AsyncDeferredPromise >> isPending [
	^ state isPending
]

{ #category : #testing }
AsyncDeferredPromise >> isRejected [
	^ state isRejected
]

{ #category : #testing }
AsyncDeferredPromise >> isSettled [
	^ state isPending not
]

{ #category : #initialization }
AsyncDeferredPromise >> newChainedPromises [
	^ AsyncErrorSafeOrderedCollection new
]

{ #category : #'private - state' }
AsyncDeferredPromise >> rejectWithError: anError [
	self subclassResponsibility
]

{ #category : #'private - state' }
AsyncDeferredPromise >> rejectWithTransformedError: anError [
	| theRejectionPromises |
	
	mutex critical: [
		self
			assert: [ state isPending ]
			description: [ 'Promise must be pending, but was ', state printString ].
		state := (AsyncRejectedPromiseState new error: anError freeze).
		theRejectionPromises := chainedPromises.
		chainedPromises := self newChainedPromises ].

	theRejectionPromises do: [ :eachPromise | eachPromise rejectWithError: anError ]
]

{ #category : #'private - accessing' }
AsyncDeferredPromise >> state [
	<return: #AsyncPromiseState>

	^ state
]

{ #category : #'api - promise' }
AsyncDeferredPromise >> then: onFulfilledBlock [
	mutex critical: [
		state isPending
			ifTrue: [
				| aResolvedPromise |

				aResolvedPromise := AsyncChainedPromise new
					previousPromise: self;
					fulfilledComputation: onFulfilledBlock.

				chainedPromises add: aResolvedPromise.
				^ aResolvedPromise ] ].

	state isFulfilled
		ifTrue: [			
			^ state value isAsyncPromise
				ifTrue: [ state value asyncThen: onFulfilledBlock ]
				ifFalse: [
					AsyncFulfilledPromise new
						value: state value;
						then: onFulfilledBlock ] ].

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
					previousPromise: self;
					fulfilledComputation: onFulfilledBlock;
					rejectedComputation: onRejectedBlock.

				chainedPromises add: aDeferredPromise.
				^ aDeferredPromise ] ].

	state isFulfilled
		ifTrue: [
			^ state value isAsyncPromise
				ifTrue: [ state value asyncThen: onFulfilledBlock ]
				ifFalse: [
					AsyncFulfilledPromise new
						value: state value;
						then: onFulfilledBlock
						otherwise: onRejectedBlock ] ].

	state isRejected
		ifTrue: [
			^ AsyncRejectedPromise new
				error: state error;
				then: onFulfilledBlock
				otherwise: onRejectedBlock ].

	^ self error: ('Unexpected state: {1}' format: { state })
]

{ #category : #'api - promise' }
AsyncDeferredPromise >> wait [
	| aCurrentState aSemaphore anAwaitResult anAwaitError  |
	
	aSemaphore := Semaphore new.
	anAwaitResult := anAwaitError := nil.
	
	aCurrentState := state.
	self
		then: [ :aResult |
			anAwaitResult := aResult.
			aSemaphore signal ]
		otherwise: [ :anError |
			anAwaitError := anError freeze.
			aSemaphore signal ].
	
	aSemaphore wait.
	anAwaitError ifNotNil: [ ^ anAwaitError ].
	^ anAwaitResult
]
