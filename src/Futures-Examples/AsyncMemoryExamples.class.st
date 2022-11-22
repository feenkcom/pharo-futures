"
Test for various scenarios where streams/sinks are leaked or prematurely gc'd
"
Class {
	#name : #AsyncMemoryExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #accessing }
AsyncMemoryExamples >> closedStreamExample [
	<gtExample>
	| sink future ending |
	ending := Interval allInstances
			inject: 12345
			into: [ :sum :each | 
				(each notEmpty and: [ each last isInteger ])
					ifTrue: [ sum + each last abs ]
					ifFalse: [ sum ] ].
	sink := AsyncCounterSink new.
	future := (1 to: ending) asAsyncStream forward: sink.
	future wait.

	self assert: sink count equals: ending.

	2 timesRepeat: [ Smalltalk garbageCollect ].

	self
		assert: (Interval allInstances noneSatisfy: [ :each | each last = ending ])
]

{ #category : #accessing }
AsyncMemoryExamples >> dirtyBlockExample [
	"Checks to ensure that streams are gc'd even when using 'dirty' blocks"
	<gtExample>
	| sink future ending |

	ending := Interval allInstances
			inject: 12345
			into: [ :sum :each | 
				(each notEmpty and: [ each last isInteger ])
					ifTrue: [ sum + each last abs ]
					ifFalse: [ sum ] ].
	sink := AsyncCounterSink new.
	future := [ :array | 
		((1 to: ending) asAsyncStream collect: [ :each | each * array last ])
			forward: sink ]
			value: {sink.
					2}.
	sink := nil.
	2 timesRepeat: [ Smalltalk garbageCollect ].

	self
		assert: (Interval allInstances noneSatisfy: [ :each | each last = ending ])
]

{ #category : #accessing }
AsyncMemoryExamples >> leakExample [
	"Checks to ensure that streams are gc'd when unreferenced by sinks"

	<gtExample>
	| sink future ending |
	ending := Interval allInstances
			inject: 12345
			into: [ :sum :each | 
				(each notEmpty and: [ each last isInteger ])
					ifTrue: [ sum + each last abs ]
					ifFalse: [ sum ] ].
	sink := AsyncCounterSink new.
	future := (1 to: ending) asAsyncStream forward: sink.

	sink := nil.
	2 timesRepeat: [ Smalltalk garbageCollect ].

	self
		assert: (Interval allInstances noneSatisfy: [ :each | each last = ending ])
]

{ #category : #accessing }
AsyncMemoryExamples >> weakExample [
	<gtExample>
	| sink future |
	sink := AsyncCounterSink new.
	future := (1 to: 1000) asAsyncStream forward: sink.

	2 timesCollect: [ Smalltalk garbageCollect ].

	future wait.
	self assert: sink count equals: 1000
]

{ #category : #accessing }
AsyncMemoryExamples >> weakGroupByExample [
	<gtExample>
	| sink1 sink2 sink3 sink4 future |
	sink1 := AsyncCounterSink new.
	sink2 := AsyncCounterSink new.
	sink3 := AsyncCounterSink new.
	sink4 := AsyncCounterSink new.

	future := (1 to: 1000) asAsyncStream
			forward: ((AsyncGroupBySink forGroupByBlock: [ :a | a odd ])
					at: true
						putSink: ((AsyncGroupBySink forGroupByBlock: [ :a | (a >> 1) odd ])
								at: true putSink: sink1;
								at: false putSink: sink2;
								yourself);
					at: false
						putSink: ((AsyncGroupBySink forGroupByBlock: [ :a | (a >> 1) odd ])
								at: true putSink: sink3;
								at: false putSink: sink4;
								yourself);
					yourself).
	2 timesRepeat: [ Smalltalk garbageCollect ].

	future wait.
	{sink1.
		sink2.
		sink3.
		sink4} do: [:each | self assert: each count equals: 250 ]
]
