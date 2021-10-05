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
AsyncStreamExamples >> filter [
	<gtExample>
	| stream evens result |
	
	stream := (1 to: 10) asAsyncStream.
	evens := stream filter: [ :x | x even ].
	
	result := evens collect wait.
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
	
	result := (flatten collectAs: String) wait.
	self assert: result equals: 'abbcccdddd'.
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> flattenStream [
	<gtExample>
	| streams |
	
	streams := (0 to: 3) asAsyncStream map: [ :x |
		(AsyncRepeatStream item: ($a asInteger + x) asCharacter)
			take: (x + 1) ].
	^ streams flatten
]

{ #category : #examples }
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

{ #category : #examples }
AsyncStreamExamples >> map [
	<gtExample>
	| evens result |
	
	evens := self mapStream.
	
	result := evens collect wait.
	self assert: result equals: #(2 4 6 8 10).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> mapStream [
	<gtExample>
	| stream |
	
	stream := (1 to: 5) asAsyncStream.
	^ stream map: [ :x | x * 2 ]
]

{ #category : #examples }
AsyncStreamExamples >> repeat [
	<gtExample>
	| stream result |
	
	stream := AsyncRepeatStream item: 42.
	
	result := (stream take: 5) collect wait.
	self assert: result equals: #(42 42 42 42 42).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> sequence [
	<gtExample>
	| collection stream result |
	
	collection := OrderedCollection newFrom: #(1 2 3 4 5).
	stream := collection asAsyncStream.
	
	result := stream collect wait.
	self assert: result equals: #(1 2 3 4 5).
	^ result
]

{ #category : #examples }
AsyncStreamExamples >> take [
	<gtExample>
	| stream first result |
	
	stream := (1 to: 10) asAsyncStream.
	first := stream take: 3.
	
	result := first collect wait.
	self assert: result equals: #(1 2 3).
	^ result
]
