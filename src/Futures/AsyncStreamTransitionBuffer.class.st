"
#Transition buffer
Is a helper buffer to fill the gap between two buffers created for different streams. {{gtClass:AsyncStreamBuffer}} loads items in chunks and is created with empty buffer. When used in the UI, this means that if a stream is replaced, the widgets would momentarily show an empty list which results in a flickering. To solve that problem, developers should use a transition buffer which tries to preload as many items as there were in the previous buffer. By doing so, we give UI a chance to preserve the scrolling possition and reduce unwanted updates.

{{gtMethod:AsyncStreamTransitionBuffer>>#bufferLoadingPromise}} is fulfilled when an underlying new buffer is ready and is able to provide a new collection of items.
"
Class {
	#name : #AsyncStreamTransitionBuffer,
	#superclass : #Object,
	#instVars : [
		'previousItems',
		'newBuffer',
		'preloadAmount',
		'executionConfiguration',
		'loadSinglesUntil'
	],
	#category : #'Futures-Buffer'
}

{ #category : #'instance creation' }
AsyncStreamTransitionBuffer class >> forStream: aStream previousBuffer: anAsyncStreamBuffer [
	^ self new
		stream: aStream
		previousBuffer: anAsyncStreamBuffer
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> at: anIndex [
	^ (newBuffer at: anIndex) ifNil: [ previousItems at: anIndex ]
]

{ #category : #'api - loading' }
AsyncStreamTransitionBuffer >> bufferLoadingPromise [
	^ newBuffer bufferLoadingPromise
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> bufferSnapshot [
	^ previousItems
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> executionConfiguration [
	^ executionConfiguration
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> loadSinglesUntil [
	^ loadSinglesUntil
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> loadSinglesUntil: aNumber [
	loadSinglesUntil := aNumber
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> newBuffer [
	^ newBuffer
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> preloadAmount [

	^ preloadAmount
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> preloadAmount: aNumber [

	preloadAmount := aNumber
]

{ #category : #'api - loading' }
AsyncStreamTransitionBuffer >> preloadUntilFoundSuchThat: aBlock [
	^ newBuffer preloadUntilFoundSuchThat: aBlock
]

{ #category : #accessing }
AsyncStreamTransitionBuffer >> size [
	"Return the current buffer length"
	^ previousItems size max: newBuffer size
]

{ #category : #'api - loading' }
AsyncStreamTransitionBuffer >> stop [
	newBuffer stop
]

{ #category : #initialization }
AsyncStreamTransitionBuffer >> stream: aStream previousBuffer: anAsyncStreamBuffer [
	previousItems := anAsyncStreamBuffer bufferSnapshot.
	preloadAmount := anAsyncStreamBuffer preloadAmount.
	loadSinglesUntil := anAsyncStreamBuffer loadSinglesUntil.
	executionConfiguration := anAsyncStreamBuffer executionConfiguration.

	newBuffer := AsyncStreamBuffer new
		preloadAmount: (previousItems size max: preloadAmount);
		loadSinglesUntil: loadSinglesUntil;
		executionConfiguration: executionConfiguration;
		stream: aStream.

	newBuffer continue then: [
		newBuffer
			preloadAmount: preloadAmount;
			loadSinglesUntil: loadSinglesUntil ]
]

{ #category : #'announcer - subscription' }
AsyncStreamTransitionBuffer >> unsubscribe: anObject [
	"Just for polymorphism with the {{gtClass:AsyncStreamBuffer}}"
]

{ #category : #'api - loading' }
AsyncStreamTransitionBuffer >> wait [
	"! Debugging and testing only !"
	"Synchronously wait for the current loading to finish"

	newBuffer wait
]
