Class {
	#name : #AsyncSinkExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncSinkExamples >> collectionSinkDefault [
	<gtExample>
	| stream sink |
	
	stream := (1 to: 10) asAsyncStream.
	
	sink := AsyncCollectionSink new.
	(sink sendAll: stream) wait.
	
	self
		assert: sink collection
		equals: (1 to: 10) asOrderedCollection.
	
	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> collectionSinkSet [
	<gtExample>
	| stream sink |
	
	stream := { 1. 1. 2. 2. 3. 3 } asAsyncStream.
	
	sink := AsyncCollectionSink forCollection: Set new.
	(sink sendAll: stream) wait.
	
	self
		assert: sink collection
		equals: ({1 . 2 .3} as: Set).
	
	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> counterSink [
	<gtExample>
	| stream sink |
	
	stream := (1 to: 42) asAsyncStream.
	
	sink := AsyncCounterSink new.
	(sink sendAll: stream) wait.
	
	self assert: sink count equals: 42.
	
	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> drainSink [
	<gtExample>
	| stream sink |
	
	stream := (1 to: 42) asAsyncStream.
	
	sink := AsyncDrainSink new.
	(sink sendAll: stream) wait.
	
	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> fanoutSink [
	<gtExample>
	| stream sinkA sinkB sink |
	
	stream := (1 to: 5) asAsyncStream.
	
	sinkA := AsyncCollectionSink new.
	sinkB := AsyncCollectionSink new.
	sink := sinkA fanout: sinkB.
	
	(sink sendAll: stream) wait.
	
	self assert: sinkA collection equals: (1 to: 5) asOrderedCollection.
	self assert: sinkB collection equals: (1 to: 5) asOrderedCollection.

	^ sink
]
