Class {
	#name : #AsyncFutureExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #documentation }
AsyncFutureExamples >> allTypesOfFutures [
	<gtExample>
	<return: #Array>
	^ ((TAsyncFuture users asArray flatCollect: [ :cls | cls withAllSubclasses ])
		copyWithoutDuplicates reject: [ :cls | cls isAbstract ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : #examples }
AsyncFutureExamples >> flatten [
	<gtExample>
	<return: #SmallInteger>
	| future result |
	future := self flattenFuture.

	result := future wait.
	self assert: result equals: 42.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> flattenFuture [
	<gtExample>
	<return: #AsyncFlattenFuture>
	| future |
	future := [ [ 42 ] asAsyncFuture ] asAsyncFuture.
	future := future flatten.

	^ future
]

{ #category : #examples }
AsyncFutureExamples >> flattenSimilarCopy [
	<gtExample>
	<return: #AsyncFlattenFuture>
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
	<return: #Array>
	| futures joinAll result |
	futures := {[ 42 ] asAsyncFuture.
			3.14 asAsyncFuture.
			9 asAsyncFuture map: [ :x | x * x ]}.

	joinAll := AsyncJoinAllFuture futures: futures.

	result := joinAll wait.
	self
		assert: result
		equals: {42.
				3.14.
				81}.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> map [
	<gtExample>
	<return: #SmallInteger>
	| future result |
	future := self mapFuture.

	result := future wait.
	self assert: result equals: 84.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> mapFuture [
	<gtExample>
	<return: #AsyncMapFuture>
	| future |
	future := self simpleFuture asAsyncFuture.
	future := future map: [ :x | x * 2 ].

	^ future
]

{ #category : #examples }
AsyncFutureExamples >> parallelWaits [
	<gtExample>
	<return: #Array>
	| totalDuration result |
	totalDuration := [ result := (AsyncJoinAllFuture
				futures: {[ 0.1 second wait ] asAsyncForkedFuture.
						[ 0.2 second wait ] asAsyncForkedFuture.
						[ 0.3 second wait ] asAsyncForkedFuture}) await wait ] timeToRun.
	self assert: totalDuration < 0.4 seconds.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> sequentialWaits [
	<gtExample>
	<return: #Array>
	| totalDuration result |
	totalDuration := [ result := (AsyncJoinAllFuture
				futures: {[ 0.1 second wait ] asAsyncFuture.
						[ 0.2 second wait ] asAsyncFuture.
						[ 0.3 second wait ] asAsyncFuture}) await wait ] timeToRun.
	self assert: totalDuration >= 0.6 seconds.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> simpleFuture [
	<gtExample>
	<return: #AsyncPollFuture>
	^ [ 21 * 2 ] asAsyncFuture
]

{ #category : #examples }
AsyncFutureExamples >> then [
	<gtExample>
	<return: #SmallInteger>
	| future result |
	future := self thenFuture.

	result := future wait.
	self assert: result equals: 84.
	^ result
]

{ #category : #examples }
AsyncFutureExamples >> thenFuture [
	<gtExample>
	<return: #AsyncFlattenFuture>
	| future |
	future := self simpleFuture asAsyncFuture.
	future := future then: [ :x | [ x * 2 ] asAsyncFuture ].

	^ future
]
