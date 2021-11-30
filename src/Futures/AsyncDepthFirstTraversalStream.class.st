Class {
	#name : #AsyncDepthFirstTraversalStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stack',
		'children',
		'roots'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncDepthFirstTraversalStream class >> root: anObject children: aSymbolOrBlock [
	^ (self new)
		root: anObject children: aSymbolOrBlock;
		yourself
]

{ #category : #initialization }
AsyncDepthFirstTraversalStream >> initialize [
	super initialize.
	stack := Stack new
]

{ #category : #'api - stream' }
AsyncDepthFirstTraversalStream >> pollNext: anAsynchronousContext [
	[ stack isEmpty ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ].
	(stack top pollNext: anAsynchronousContext)
		ifReady:
			[ :each | 
			each value isSome
				ifTrue:
					[ stack push: (children value: each value value) asAsyncStream.
					^ AsyncPoll ready: (AsyncOptionalValue some: each value value) ]
				ifFalse: [ stack pop ] ]
		ifPending: [ :each | ^ each ] ] repeat
]

{ #category : #'api - stream copy' }
AsyncDepthFirstTraversalStream >> postSimilarCopy [
	stack := Stack with: roots asAsyncStream
]

{ #category : #initialization }
AsyncDepthFirstTraversalStream >> root: anObject children: aSelectorOrBlock [
	self roots: {anObject} children: aSelectorOrBlock
]

{ #category : #initialization }
AsyncDepthFirstTraversalStream >> roots: aCollection children: aSelectorOrBlock [
	roots := aCollection.
	stack := Stack with: aCollection asAsyncStream.
	children := aSelectorOrBlock
]
