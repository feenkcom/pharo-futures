Class {
	#name : #AsyncFutureThreadPoolCounterExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> newCounter [
	<gtExample>
	| aCounter |

	"we simulate time for precise testing"
	aCounter := AsyncFutureThreadPoolCounter2 withTime: 0 seconds.
	self assert: aCounter amountOfPings equals: 0.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(0 0 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping000 [
	<gtExample>
	| aCounter |
	
	aCounter := self newCounter.
	aCounter ping.
	self assert: aCounter amountOfPings equals: 1.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(1 0 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping001 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping000.
	aCounter setTime: 1 second.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 2.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(2 0 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping004 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping001.
	aCounter setTime: 4 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 3.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 0 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping005 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping004.
	aCounter setTime: 5 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 4.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 1 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping009 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping005.
	aCounter setTime: 9 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 5.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping010 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping009.
	aCounter setTime: 10 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 6.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping015 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping010.
	aCounter setTime: 15 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 7.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping020 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping015.
	aCounter setTime: 20 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 8.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping025 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping020.
	aCounter setTime: 25 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 9.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping030 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping025.
	aCounter setTime: 30 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 10.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping035 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping030.
	aCounter setTime: 35 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 11.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping040 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping035.
	aCounter setTime: 40 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 12.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping045 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping040.
	aCounter setTime: 45 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 13.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 1 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping050 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping045.
	aCounter setTime: 50 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 14.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 1 1 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping055 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping050.
	aCounter setTime: 55 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 15.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 1 1 1)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping059 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping055.
	aCounter setTime: 59 seconds.
	aCounter ping.
	
	self assert: aCounter amountOfPings equals: 16.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping060 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping059.
	aCounter setTime: 60 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 5.
	self assert: aCounter amountOfPings equals: 14.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(1 2 1 1 1 1 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping061 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping060.
	aCounter setTime: 61 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 5.
	self assert: aCounter amountOfPings equals: 15.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(2 2 1 1 1 1 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping064 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping061.
	aCounter setTime: 64 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 5.
	self assert: aCounter amountOfPings equals: 16.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 2 1 1 1 1 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping065 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping064.
	aCounter setTime: 65 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 10.
	self assert: aCounter amountOfPings equals: 15.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 1 1 1 1 1 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping090 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping065.
	aCounter setTime: 90 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 35.
	self assert: aCounter amountOfPings equals: 11.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 1 0 0 0 0 1 1 1 1 1 2)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping115 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping090.
	aCounter setTime: 115 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 60.
	self assert: aCounter amountOfPings equals: 6.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(3 1 0 0 0 0 1 0 0 0 0 1)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping120 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping115.
	aCounter setTime: 120 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 65.
	self assert: aCounter amountOfPings equals: 4.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(1 1 0 0 0 0 1 0 0 0 0 1)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping240 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping120.
	aCounter setTime: 240 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 240.
	self assert: aCounter amountOfPings equals: 1.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(1 0 0 0 0 0 0 0 0 0 0 0)).
	
	^ aCounter
]

{ #category : #examples }
AsyncFutureThreadPoolCounterExamples >> ping380 [
	<gtExample>
	| aCounter |
	
	aCounter := self ping240.
	aCounter setTime: 380 seconds.
	aCounter ping.
	
	self assert: aCounter previousSeconds equals: 380.
	self assert: aCounter amountOfPings equals: 1.
	self assert: aCounter pingsArray equals: (WordArray withAll: #(0 0 0 0 1 0 0 0 0 0 0 0)).
	
	^ aCounter
]
