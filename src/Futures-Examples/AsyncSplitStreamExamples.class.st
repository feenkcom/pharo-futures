Class {
	#name : #AsyncSplitStreamExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Streams'
}

{ #category : #examples }
AsyncSplitStreamExamples >> splitWithSeparatorInTheBeginning [
	<gtExample>
	| groups |
	
	groups := (#(. 1 2 3) asAsyncStream splitOn: [ :each | each = #'.' ]) toArray wait.
	self assert: groups size equals: 2.
	self assert: groups first equals: #().
	self assert: groups second equals: #(1 2 3).
	
	^ groups
]

{ #category : #examples }
AsyncSplitStreamExamples >> splitWithSeparatorInTheEnd [
	<gtExample>
	| groups |
	
	groups := (#(1 2 3 .) asAsyncStream splitOn: [ :each | each = #'.' ]) toArray wait.
	self assert: groups size equals: 2.
	self assert: groups first equals: #(1 2 3).
	self assert: groups second equals: #().
	
	^ groups
]

{ #category : #examples }
AsyncSplitStreamExamples >> splitWithSeparatorInTheMiddle [
	<gtExample>
	| groups |
	
	groups := (#(1 . 2 3) asAsyncStream splitOn: [ :each | each = #'.' ]) toArray wait.
	self assert: groups size equals: 2.
	self assert: groups first equals: #(1).
	self assert: groups second equals: #(2 3).
	
	^ groups
]

{ #category : #examples }
AsyncSplitStreamExamples >> splitWithSeparatorsInTheBeginning [
	<gtExample>
	| groups |
	
	groups := (#(. . 1 2 3) asAsyncStream splitOn: [ :each | each = #'.' ]) toArray wait.
	self assert: groups size equals: 3.
	self assert: groups first equals: #().
	self assert: groups second equals: #().
	self assert: groups third equals: #(1 2 3).
	
	^ groups
]
