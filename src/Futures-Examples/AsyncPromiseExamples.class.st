Class {
	#name : #AsyncPromiseExamples,
	#superclass : #Object,
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
