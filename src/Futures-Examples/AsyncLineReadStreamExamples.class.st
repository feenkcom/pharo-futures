Class {
	#name : #AsyncLineReadStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Streams'
}

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheEnd [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr , String cr) asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheEndIncludingLastLine [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr , String cr) asAsyncStream lines
			emitEmptyLastLine toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: ''.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr , String cr , 'world') asAsyncStream lines
			toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheBeginning [
	<gtExample>
	<return: #Array>
	| lines |
	lines := (String cr , 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheEnd [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheEndIncludingLastLine [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr) asAsyncStream lines emitEmptyLastLine toArray
			wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String cr , 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfCrInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String crlf , String cr , 'world') asAsyncStream lines
			toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfCrlfInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String crlf , String crlf , 'world') asAsyncStream lines
			toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheBeginning [
	<gtExample>
	<return: #Array>
	| lines |
	lines := (String crlf , 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheEnd [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String crlf) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String crlf , 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheBeginning [
	<gtExample>
	<return: #Array>
	| lines |
	lines := (String lf , 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheEnd [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String lf) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String lf , 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfLfInTheMiddle [
	<gtExample>
	<return: #Array>
	| lines |
	lines := ('hello' , String lf , String lf , 'world') asAsyncStream lines
			toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.

	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithoutLineBreaks [
	<gtExample>
	<return: #Array>
	| lines |
	lines := 'hello' asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.

	^ lines
]
