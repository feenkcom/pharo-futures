Class {
	#name : #AsyncFutureExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #documentation }
AsyncFutureExamples >> allTypesOfFutures [
	<gtExample>
	
	^ ((TAsyncFuture users asArray
		flatCollect: [ :cls | cls withAllSubclasses ])
		copyWithoutDuplicates
		reject: [ :cls | cls isAbstract ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : #examples }
AsyncFutureExamples >> flatten [
	<gtExample>
	| future result |
	
	future := self flattenFuture.

	result := future wait.
	self assert: result equals: 42.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> flattenFuture [
	<gtExample>
	| future |
	
	future := [ [ 42 ] asAsyncFuture ] asAsyncFuture.
	future := future flatten.

	^ future
]

{ #category : #examples }
AsyncFutureExamples >> flattenSimilarCopy [
	<gtExample>
	| future |
	
	future := self flattenFuture.
	self assert: future wait equals: 42.
	
	future := future asyncSimilarCopy.
	self assert: future wait equals: 42.
	
	^ future asyncSimilarCopy
]

{ #category : #examples }
AsyncFutureExamples >> joinAll [
	<gtExample>
	| futures joinAll result |
	
	futures := { 
		[ 42 ] asAsyncFuture.
		3.14 asAsyncFuture.
		9 asAsyncFuture map: [ :x | x * x ].
	}.
	
	joinAll := AsyncJoinAllFuture futures: futures.

	result := joinAll wait.
	self assert: result equals: { 42. 3.14. 81 }.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> map [
	<gtExample>
	| future result |
	
	future := self mapFuture.

	result := future wait.
	self assert: result equals: 84.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> mapFuture [
	<gtExample>
	| future |
	
	future := self simpleFuture asAsyncFuture.
	future := future map: [ :x | x * 2 ].

	^ future
]

{ #category : #examples }
AsyncFutureExamples >> parallelWaits [
	<gtExample>
	| totalDuration result |
	totalDuration := [ 
		result := (AsyncJoinAllFuture futures: {
			[ 0.1 second wait ] asAsyncForkedFuture.
			[ 0.2 second wait ] asAsyncForkedFuture.
			[ 0.3 second wait ] asAsyncForkedFuture.
		}) await wait ] timeToRun.
	self assert:  totalDuration < 0.4 seconds.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> sequentialWaits [
	<gtExample>
	| totalDuration result |
	totalDuration := [ 
		result := (AsyncJoinAllFuture futures: {
			[ 0.1 second wait ] asAsyncFuture.
			[ 0.2 second wait ] asAsyncFuture.
			[ 0.3 second wait ] asAsyncFuture.
		}) await wait ] timeToRun.
	self assert:  totalDuration >= 0.6 seconds.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> simpleFuture [
	<gtExample>

	^ [ 21 * 2 ] asAsyncFuture
]

{ #category : #examples }
AsyncFutureExamples >> then [
	<gtExample>
	| future result |
	
	future := self thenFuture.

	result := future wait.
	self assert: result equals: 84.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> thenFuture [
	<gtExample>
	| future |
	
	future := self simpleFuture asAsyncFuture.
	future := future then: [ :x | [ x * 2 ] asAsyncFuture ].

	^ future
]
