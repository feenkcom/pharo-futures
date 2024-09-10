Class {
	#name : #AsyncLineReadStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Streams'
}

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheEnd [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr, String cr) asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheEndIncludingLastLine [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr, String cr) asAsyncStream lines emitEmptyLastLine toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: ''.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrCrInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr, String cr, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheBeginning [
	<gtExample>
	| lines |
	
	lines := (String cr, 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheEnd [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheEndIncludingLastLine [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr) asAsyncStream lines emitEmptyLastLine toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String cr, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfCrInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String crlf, String cr, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfCrlfInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String crlf, String crlf, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheBeginning [
	<gtExample>
	| lines |
	
	lines := (String crlf, 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheEnd [
	<gtExample>
	| lines |
	
	lines := ('hello', String crlf) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithCrlfInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String crlf, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheBeginning [
	<gtExample>
	| lines |
	
	lines := (String lf, 'hello') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: ''.
	self assert: lines second equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheEnd [
	<gtExample>
	| lines |
	
	lines := ('hello', String lf) asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String lf, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 2.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithLfLfInTheMiddle [
	<gtExample>
	| lines |
	
	lines := ('hello', String lf, String lf, 'world') asAsyncStream lines toArray wait.
	self assert: lines size equals: 3.
	self assert: lines first equals: 'hello'.
	self assert: lines second equals: ''.
	self assert: lines third equals: 'world'.
	
	^ lines
]

{ #category : #examples }
AsyncLineReadStreamExamples >> streamWithoutLineBreaks [
	<gtExample>
	| lines |
	
	lines := 'hello' asAsyncStream lines toArray wait.
	self assert: lines size equals: 1.
	self assert: lines first equals: 'hello'.
	
	^ lines
]
