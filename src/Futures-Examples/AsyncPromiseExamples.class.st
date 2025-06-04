Class {
	#name : #AsyncPromiseExamples,
	#superclass : #Object,
	#instVars : [
		'rootPromise',
		'promiseA',
		'subPromiseA',
		'promiseB'
	],
	#category : #'Futures-Examples'
}

{ #category : #documentation }
AsyncPromiseExamples >> allTypesOfPromises [
	<gtExample>
	<return: #Array>
	^ ((TAsyncPromise users asArray flatCollect: [ :cls | cls withAllSubclasses ])
		copyWithoutDuplicates reject: [ :cls | cls isAbstract ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : #'examples - chaining' }
AsyncPromiseExamples >> chainedFulfilledPromise [
	<gtExample>
	<return: #AsyncFulfilledPromise>
	rootPromise := AsyncFulfilledPromise new value: 42.
	promiseA := rootPromise then: [ :aNumber | aNumber / 0 ].

	subPromiseA := promiseA
			then: [ :aValue | aValue class ]
			otherwise: [ :anError | anError class ].	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
	propagate the value to other promises"
	promiseB := rootPromise
			then: [ :aNumber | aNumber * 2 ]
			otherwise: [ :anError | 0 ].

	self assert: promiseA class equals: AsyncRejectedPromise.
	self assert: promiseA error class equals: ZeroDivide.

	self assert: subPromiseA class equals: AsyncFulfilledPromise.
	self assert: subPromiseA value equals: ZeroDivide.

	self assert: promiseB class equals: AsyncFulfilledPromise.
	self assert: promiseB value equals: 84.

	^ rootPromise
]

{ #category : #'examples - chaining' }
AsyncPromiseExamples >> chainedPendingPromise [
	<gtExample>
	<return: #AsyncManualPromise>
	rootPromise := AsyncManualPromise new.
	promiseA := rootPromise then: [ :aNumber | aNumber / 0 ].

	subPromiseA := promiseA
			then: [ :aValue | aValue class ]
			otherwise: [ :anError | anError class ].	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
	propagate the value to other promises"
	promiseB := rootPromise
			then: [ :aNumber | aNumber * 2 ]
			otherwise: [ :anError | 0 ].

	self assert: promiseA class equals: AsyncChainedPromise.
	self assert: promiseA isPending.
	self assert: promiseA isSettled not.

	self assert: subPromiseA class equals: AsyncChainedPromise.
	self assert: subPromiseA isPending.
	self assert: subPromiseA isSettled not.

	self assert: promiseB class equals: AsyncChainedPromise.
	self assert: promiseB isPending.
	self assert: promiseB isSettled not.

	^ rootPromise
]

{ #category : #'examples - chaining' }
AsyncPromiseExamples >> chainedRejectedPromise [
	<gtExample>
	<return: #AsyncRejectedPromise>
	rootPromise := AsyncRejectedPromise new
			error: ([ #() first ] on: Error do: [ :e | e freeze ]).
	promiseA := rootPromise then: [ :aValue | 42 ] otherwise: [ :anError | 1 / 0 ].

	subPromiseA := promiseA
			then: [ :aValue | aValue class ]
			otherwise: [ :anError | anError class ].	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
	propagate the value to other promises"
	promiseB := rootPromise
			then: [ :aNumber | aNumber * 2 ]
			otherwise: [ :anError | 0 ].

	self assert: promiseA class equals: AsyncRejectedPromise.
	self assert: promiseA error class equals: ZeroDivide.

	self assert: subPromiseA class equals: AsyncFulfilledPromise.
	self assert: subPromiseA value equals: ZeroDivide.

	self assert: promiseB class equals: AsyncFulfilledPromise.
	self assert: promiseB value equals: 0.

	^ rootPromise
]

{ #category : #'examples - chaining' }
AsyncPromiseExamples >> fulfillRootPromise [
	<gtExample>
	<return: #AsyncManualPromise>
	| aRootPromise |
	aRootPromise := self chainedPendingPromise.
	aRootPromise fulfillWithValue: 42.

	self assert: aRootPromise isFulfilled.
	self assert: aRootPromise state value equals: 42.

	self assert: promiseA isRejected.
	self assert: promiseA state error class equals: ZeroDivide.

	self assert: subPromiseA isFulfilled.
	self assert: subPromiseA state value equals: ZeroDivide.

	self assert: promiseB isFulfilled.
	self assert: promiseB state value equals: 84.

	^ aRootPromise
]

{ #category : #examples }
AsyncPromiseExamples >> fulfilledPromise [
	<gtExample>
	<return: #AsyncFulfilledPromise>
	^ 42 asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> promiseResolvingToString [
	<gtExample>
	<return: #AsyncFuturePromise>
	^ [ 2 seconds wait.
	'Promised value' ] asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> promiseWithError [
	<gtExample>
	<return: #AsyncFuturePromise>
	^ [ 2 seconds wait.
	1 / 0 ] asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> rejectedPromise [
	<gtExample>
	<return: #AsyncRejectedPromise>
	^ [ 1 / 0 ] on: Error do: #asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> rejectedPromiseWithOtherwise [
	<gtExample>
	<return: #AsyncChainedPromise>
	| aPromise |
	aPromise := [ 1 / 0 ] asAsyncPromise then: [ :n | n * 2 ] otherwise: [ :e | 0 ].

	self assert: aPromise wait equals: 0.

	^ aPromise
]
