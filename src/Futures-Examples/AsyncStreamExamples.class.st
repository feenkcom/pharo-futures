Class {
	#name : #AsyncStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #documentation }
AsyncStreamExamples >> allTypesOfStreams [
	<gtExample>
	
	^ ((TAsyncStream users asArray
		flatCollect: [ :cls | cls withAllSubclasses ])
		copyWithoutDuplicates
		reject: [ :cls | cls isAbstract ])
		sorted: [ :a :b | a name < b name ]
]

{ #category : #examples }
AsyncStreamExamples >> cachedStream [
	<gtExample>
	| count stream streamCopy |
	
	count := 0.

	stream := (1 to: 5) asAsyncStream map: [ :each |
		count := count + 1.
		each * 2 ].
	stream := stream cached.
	
	self assert: stream toArray wait equals: #(2 4 6 8 10).
	self assert: count equals: 5.
	
	streamCopy := stream asyncSimilarCopy.
	self assert: streamCopy toArray wait equals: #(2 4 6 8 10).
	"the copy of the stream returns items from the cache which does not increase the counter"
	self assert: count equals: 5.

	^ stream
]

{ #category : #examples }
AsyncStreamExamples >> chunks [
	<gtExample>
	| chunks result |

	chunks := self chunksStream.
	
	result := (chunks to: Array) wait.
	self assert: result equals: {
		{ 1 . 2 . 3 }.
		{ 4 . 5 . 6 }.
		{ 7 . 8 . 9 }.
		{ 10. 11 } }.
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> chunksStream [
	<gtExample>
	| stream |
	
	stream := (1 to: 11) asAsyncStream.
	^ stream chunks: 3
]

{ #category : #examples }
AsyncStreamExamples >> filter [
	<gtExample>
	| stream evens result |
	
	stream := (1 to: 10) asAsyncStream.
	evens := stream filter: [ :x | x even ].
	
	result := evens toArray wait.
	self assert: result equals: #(2 4 6 8 10).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> filterStream [
	<gtExample>
	| stream |
	
	stream := (1 to: 10) asAsyncStream.
	^ stream filter: [ :x | x even ]
]

{ #category : #examples }
AsyncStreamExamples >> flatten [
	<gtExample>
	| flatten result |

	flatten := self flattenStream.
	
	result := (flatten to: String) wait.
	self assert: result equals: 'abbcccdddd'.
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> flattenStream [
	<gtExample>
	| streams |
	
	streams := (0 to: 3) asAsyncStream collect: [ :x |
		(AsyncRepeatStream item: ($a asInteger + x) asCharacter)
			take: (x + 1) ].
	^ streams flatten
]

{ #category : #examples }
AsyncStreamExamples >> forEach [
	<gtExample>
	| stream result forEach |

	stream := (1 to: 6) asAsyncStream.
	
	result := OrderedCollection new.
	forEach := stream forEach: [ :each | result add: each ].
	
	self assert: forEach wait.
	self
		assert: result
		equals: {  1 . 2 . 3 . 4 . 5 . 6 } asOrderedCollection.

	^ result
]

{ #category : #examples }
AsyncStreamExamples >> fuse [
	<gtExample>
	| stream fuse result |
	
	stream := (AsyncRepeatStream item: 7) take: 3.
	fuse := stream fuse.

	self assert: fuse isDone not.
	result := fuse toArray wait.
	self assert: result equals: #(7 7 7).
	self assert: fuse isDone.
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> map [
	<gtExample>
	| evens result |
	
	evens := self mapStream.
	
	result := evens toArray wait.
	self assert: result equals: #(2 4 6 8 10).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> mapStream [
	<gtExample>
	| stream |
	
	stream := (1 to: 5) asAsyncStream.
	^ stream collect: [ :x | x * 2 ]
]

{ #category : #examples }
AsyncStreamExamples >> repeat [
	<gtExample>
	| stream result |
	
	stream := AsyncRepeatStream item: 42.
	
	result := (stream take: 5) toArray wait.
	self assert: result equals: #(42 42 42 42 42).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> sequence [
	<gtExample>
	| collection stream result |
	
	collection := OrderedCollection newFrom: #(1 2 3 4 5).
	stream := collection asAsyncStream.
	
	result := stream toArray wait.
	self assert: result equals: #(1 2 3 4 5).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> smalltalkApiAlias [
	<gtExample>
	| result forEach |
	
	result := OrderedCollection new.
	
	forEach := (((1 to: 6) asAsyncStream
		collect: [ :each | each + 10 ])
		select: [ :each | each even ])
		do: [ :each | result add: each ].
	
	self assert: forEach wait.
	self
		assert: result
		equals: {  12 . 14 . 16 } asOrderedCollection.

	^ result
]

{ #category : #examples }
AsyncStreamExamples >> take [
	<gtExample>
	| stream first result |
	
	stream := (1 to: 10) asAsyncStream.
	first := stream take: 3.
	
	result := first toArray wait.
	self assert: result equals: #(1 2 3).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> terminatable [
	<gtExample>
	| stream |

	stream := self terminatableStream.
	"Terminate a stream after taking first 100 items"
	((stream take: 100) toArray then: [ stream terminate ]) wait.
	
	"An attempt to take more items from the terminated stream does not produce items"
	self assert: (stream take: 10) toArray wait equals: #().

	^ stream
]

{ #category : #examples }
AsyncStreamExamples >> terminatableStream [
	<gtExample>
	| stream |

	stream := (1 to: 100000) asAsyncStream.
	^ stream terminatable
]
