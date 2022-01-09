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
	
	^ ((TAsyncPromise users asArray
		flatCollect: [ :cls | cls withAllSubclasses ])
		copyWithoutDuplicates
		reject: [ :cls | cls isAbstract ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : #'examples - chaining' }
AsyncPromiseExamples >> chainedFulfilledPromise [
	<gtExample>

	rootPromise := AsyncFulfilledPromise new value: 42.
	promiseA := rootPromise
		then: [ :aNumber | aNumber / 0 ].

	subPromiseA := promiseA
		then: [ :aValue | aValue class ]
		otherwise: [ :anError | anError class ].

	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
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

	rootPromise := AsyncPendingPromise new.
	promiseA := rootPromise
		then: [ :aNumber | aNumber / 0 ].

	subPromiseA := promiseA
		then: [ :aValue | aValue class ]
		otherwise: [ :anError | anError class ].

	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
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

	rootPromise := AsyncRejectedPromise new error: ([ #() first ] on: Error do: [ :e | e freeze ]).
	promiseA := rootPromise
		then: [ :aValue | 42 ]
		otherwise: [ :anError | 1 / 0 ].

	subPromiseA := promiseA
		then: [ :aValue | aValue class ]
		otherwise: [ :anError | anError class ].

	"we create promise B after promise A to test that even if a previous promise's computation fails we can still
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
	
	^ 42 asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> promiseResolvingToString [
	<gtExample>
	
	^ [ 2 seconds wait. 'Promised value' ] asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> promiseWithError [
	<gtExample>
	
	^ [ 2 seconds wait. 1 / 0 ] asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> rejectedPromise [
	<gtExample>
	
	^ [ 1/ 0 ] on: Error do: #asAsyncPromise
]

{ #category : #examples }
AsyncPromiseExamples >> rejectedPromiseWithOtherwise [
	<gtExample>
	| aPromise |

	aPromise := [ 1 / 0 ] asAsyncPromise
		then: [ :n | n * 2 ]
		otherwise: [ :e | 0 ].
	
	self assert: aPromise wait equals: 0.
	
	^ aPromise
]
