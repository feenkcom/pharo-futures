Class {
	#name : #AsyncStreamBufferExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncStreamBufferExamples >> bufferOnLargeStream [
	<gtExample>
	| aBuffer |

	aBuffer := AsyncStreamBuffer new stream: (1 to: 10000) asAsyncStream.
	self assert: aBuffer size equals: 0.
	"buffer tries to load the first batch of items only after accessing the #size or #at:"
	aBuffer wait.

	self assert: aBuffer size equals: 20.
	
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> getAtLast [
	<gtExample>
	| aBuffer theLastIndex |

	aBuffer := self bufferOnLargeStream.
	theLastIndex := aBuffer size.
	
	self assert: (aBuffer at: theLastIndex) equals: theLastIndex.
	
	"asking for the last items triggers a preloading"
	aBuffer wait.

	self assert: aBuffer size equals: 40.
	
	^ aBuffer
]

{ #category : #examples }
AsyncStreamBufferExamples >> preloadUntilFound [
	<gtExample>
	| aBuffer theItem |

	aBuffer := self bufferOnLargeStream.
	theItem := (aBuffer preloadUntilFoundSuchThat: [ :each | each = 510 ]) wait.
	
	self assert: theItem index equals: 510.
	self assert: theItem item equals: 510.
	self assert: aBuffer size equals: 520.

	^ aBuffer
]
