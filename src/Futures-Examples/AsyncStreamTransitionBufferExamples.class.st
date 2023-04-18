Class {
	#name : #AsyncStreamTransitionBufferExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Buffer'
}

{ #category : #accessing }
AsyncStreamTransitionBufferExamples >> bufferOnLargeStream [
	<gtExample>
	| aTransitionBuffer aPreviousBuffer |
	aPreviousBuffer := AsyncStreamBufferExamples new bufferOnLargeStream.

	aTransitionBuffer := AsyncStreamTransitionBuffer
			forStream: (1 to: 10000) asAsyncStream
			previousBuffer: aPreviousBuffer.

	self assert: aPreviousBuffer size equals: 20.
	self assert: aTransitionBuffer size equals: 20.
			
	^ aTransitionBuffer
]

{ #category : #accessing }
AsyncStreamTransitionBufferExamples >> getAtLast [
	<gtExample>
	| aTransitionBuffer theLastIndex |
	aTransitionBuffer := self bufferOnLargeStream.

	self assert: aTransitionBuffer size equals: 20.

	theLastIndex := aTransitionBuffer size.

	self assert: (aTransitionBuffer at: theLastIndex) equals: theLastIndex.

	^ aTransitionBuffer
]

{ #category : #accessing }
AsyncStreamTransitionBufferExamples >> preloadUntilFound [
	<gtExample>
	| aTransitionBuffer theItem aScanPromise |
	aTransitionBuffer := self bufferOnLargeStream.

	self assert: aTransitionBuffer size equals: 20.

	aScanPromise := aTransitionBuffer preloadUntilFoundSuchThat: [ :each | each = 510 ].
	aTransitionBuffer wait.
	
	self assert: aTransitionBuffer size equals: 20.
	self assert: aTransitionBuffer newBuffer size >= 510.
	self assert: aScanPromise isPending.
	
	aTransitionBuffer fulfillPendingScanPromises.
	
	self assert: aTransitionBuffer size equals: 20.
	self assert: aTransitionBuffer newBuffer size >= 510.
	self assert: aScanPromise isFulfilled.
	
	theItem := aScanPromise wait.
	
	self assert: theItem isNotNil.
	self assert: theItem index equals: 510.
	self assert: theItem item equals: 510.
	self assert: aTransitionBuffer size equals: 20.
	self assert: aTransitionBuffer newBuffer size >= 510.

	^ aTransitionBuffer
]
