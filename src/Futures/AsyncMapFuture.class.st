Class {
	#name : 'AsyncMapFuture',
	#superclass : 'Object',
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future',
		'mapBlock'
	],
	#category : 'Futures-Future'
}

{ #category : 'instance creation' }
AsyncMapFuture class >> future: aFuture mapBlock: aBlock [
	^ self new future: aFuture mapBlock: aBlock
]

{ #category : 'initialization' }
AsyncMapFuture >> future: aFuture mapBlock: aBlock [
	future := aFuture.
	mapBlock := aBlock
]

{ #category : 'api - future' }
AsyncMapFuture >> poll: anAsynchronousContext [
	^ (future poll: anAsynchronousContext)
		ifReady: [ :aReadyPoll | aReadyPoll map: mapBlock ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]
