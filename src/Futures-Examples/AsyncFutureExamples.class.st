Class {
	#name : 'AsyncFutureExamples',
	#superclass : 'Object',
	#category : 'Futures-Examples'
}

{ #category : 'examples' }
AsyncFutureExamples >> joinAll [
	<gtExample>
	| futures joinAll result |
	
	futures := { 
		[ 42 ] asFuture.
		3.14 asFuture.
		9 asFuture map: [ :x | x * x ].
	}.
	
	joinAll := AsyncJoinAllFuture futures: futures.

	result := joinAll wait.
	self assert: result equals: { 42. 3.14. 81 }.
	^ result
]

{ #category : 'examples' }
AsyncFutureExamples >> map [
	<gtExample>
	| future result |
	
	future := self mapFuture.

	result := future wait.
	self assert: result equals: 84.
	^ result
]

{ #category : 'examples' }
AsyncFutureExamples >> mapFuture [
	<gtExample>
	| future |
	
	future := [ 42 ] asFuture.
	future := future map: [ :x | x * 2 ].

	^ future
]
