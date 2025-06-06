Class {
	#name : #AsyncSinkExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Sinks'
}

{ #category : #examples }
AsyncSinkExamples >> collectionSinkDefault [
	<gtExample>
	<return: #AsyncCollectionSink>
	| stream sink |
	stream := (1 to: 10) asAsyncStream.

	sink := AsyncCollectionSink new.
	(sink sendAll: stream) wait.

	self assert: sink collection equals: (1 to: 10) asOrderedCollection.

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> collectionSinkSet [
	<gtExample>
	<return: #AsyncCollectionSink>
	| stream sink |
	stream := {1.
			1.
			2.
			2.
			3.
			3} asAsyncStream.

	sink := AsyncCollectionSink forCollection: Set new.
	(sink sendAll: stream) wait.

	self
		assert: sink collection
		equals: ({1.
				2.
				3} as: Set).

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> counterSink [
	<gtExample>
	<return: #AsyncCounterSink>
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
	<return: #AsyncDrainSink>
	| stream sink |
	stream := (1 to: 42) asAsyncStream.

	sink := AsyncDrainSink new.
	(sink sendAll: stream) wait.

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> fanoutSink [
	<gtExample>
	<return: #AsyncFanoutSink>
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

{ #category : #examples }
AsyncSinkExamples >> foldSink [
	<gtExample>
	<return: #AsyncFoldSink>
	| stream sink |
	stream := (1 to: 5) asAsyncStream.

	sink := AsyncFoldSink fold: [ :sum :each | sum + each ].
	(sink sendAll: stream) wait.

	self assert: sink value equals: 1 + 2 + 3 + 4 + 5.

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> groupBySink [
	<gtExample>
	<return: #AsyncGroupBySink>
	| stream even odd sink |
	stream := (1 to: 10) asAsyncStream.

	even := AsyncCollectionSink new.
	odd := AsyncCollectionSink new.

	sink := AsyncGroupBySink new
			groupBy: [ :each | each even ];
			at: true putSink: even;
			at: false putSink: odd.

	(sink sendAll: stream) wait.

	self
		assert: even collection
		equals: {2.
				4.
				6.
				8.
				10} asOrderedCollection.
	self
		assert: odd collection
		equals: {1.
				3.
				5.
				7.
				9} asOrderedCollection.

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> injectIntoSink [
	<gtExample>
	<return: #AsyncFoldSink>
	| stream sink |
	stream := (1 to: 5) asAsyncStream.

	sink := AsyncFoldSink inject: 0 into: [ :sum :each | sum + each ].
	(sink sendAll: stream) wait.

	self assert: sink value equals: 1 + 2 + 3 + 4 + 5.

	^ sink
]

{ #category : #examples }
AsyncSinkExamples >> peekSink [
	<gtExample>
	<return: #AsyncPeekSink>
	| stream sink |
	stream := (1 to: 5) asAsyncStream.

	sink := AsyncPeekSink new.
	(sink sendAll: stream) wait.

	self assert: sink value equals: 5.

	^ sink
]
