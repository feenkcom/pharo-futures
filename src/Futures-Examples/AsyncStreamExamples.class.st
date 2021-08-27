Class {
	#name : 'AsyncStreamExamples',
	#superclass : 'Object',
	#category : 'Futures-Examples'
}

{ #category : 'examples' }
AsyncStreamExamples >> filter [
	<gtExample>
	| stream evens result |
	
	stream := (1 to: 10) asAsyncStream.
	evens := stream filter: [ :x | x even ].
	
	result := evens collect wait.
	self assert: result equals: #(2 4 6 8 10).
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> flatten [
	<gtExample>
	| streams flatten result |
	
	streams := (0 to: 3) asAsyncStream map: [ :x |
		(AsyncRepeatStream item: ($a asInteger + x) asCharacter)
			take: (x + 1) ].
	flatten := streams flatten.
	
	result := (flatten collectAs: String) wait.
	self assert: result equals: 'abbcccdddd'.
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> fuse [
	<gtExample>
	| stream fuse result |
	
	stream := (AsyncRepeatStream item: 7) take: 3.
	fuse := stream fuse.

	self assert: fuse isDone not.
	result := fuse collect wait.
	self assert: result equals: #(7 7 7).
	self assert: fuse isDone.
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> map [
	<gtExample>
	| stream evens result |
	
	stream := (1 to: 5) asAsyncStream.
	evens := stream map: [ :x | x * 2 ].
	
	result := evens collect wait.
	self assert: result equals: #(2 4 6 8 10).
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> repeat [
	<gtExample>
	| stream result |
	
	stream := AsyncRepeatStream item: 42.
	
	result := (stream take: 5) collect wait.
	self assert: result equals: #(42 42 42 42 42).
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> sequence [
	<gtExample>
	| collection stream result |
	
	collection := OrderedCollection newFrom: #(1 2 3 4 5).
	stream := collection asAsyncStream.
	
	result := stream collect wait.
	self assert: result equals: #(1 2 3 4 5).
	^ result
]

{ #category : 'examples' }
AsyncStreamExamples >> take [
	<gtExample>
	| stream first result |
	
	stream := (1 to: 10) asAsyncStream.
	first := stream take: 3.
	
	result := first collect wait.
	self assert: result equals: #(1 2 3).
	^ result
]
