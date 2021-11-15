"
#Map future
Map future's output to a different type, returning a new future of the resulting type.
This is useful to chain along a computation once a future has been resolved.

##Example
{{gtExample:AsyncFutureExamples>>map}}
"
Class {
	#name : #AsyncMapFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future',
		'mapBlock'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncMapFuture class >> future: aFuture mapBlock: aBlock [
	^ self new future: aFuture mapBlock: aBlock
]

{ #category : #initialization }
AsyncMapFuture >> future: aFuture mapBlock: aBlock [
	future := aFuture.
	mapBlock := aBlock
]

{ #category : #'api - future' }
AsyncMapFuture >> poll: anAsynchronousContext [
	^ (future poll: anAsynchronousContext)
		ifReady: [ :aReadyPoll | aReadyPoll map: mapBlock ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - future copy' }
AsyncMapFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy
]
