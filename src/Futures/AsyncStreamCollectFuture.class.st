Class {
	#name : #AsyncStreamCollectFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'species',
		'outputStream'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncStreamCollectFuture class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'instance creation' }
AsyncStreamCollectFuture class >> stream: anAsyncStream species: aClass [
	^ self new
		stream: anAsyncStream;
		species: aClass
]

{ #category : #initialization }
AsyncStreamCollectFuture >> initialize [
	super initialize.
	
	species := Array.
	outputStream := nil
]

{ #category : #'api - future' }
AsyncStreamCollectFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	outputStream ifNil: [
		outputStream := self privateCreateWriteStream ].

	[ 
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :nextItem | self privateNextPut: nextItem ]
					ifNone: [ ^ AsyncPoll ready: self privateFinish ]
			]
			ifPending: [ :aPendingPoll | ^ aPendingPoll ]
	] repeat
]

{ #category : #'private - streaming' }
AsyncStreamCollectFuture >> privateCreateWriteStream [
	^ (species inheritsFrom: HashedCollection)
		ifTrue: [ species new: stream sizeHint approximateAmount ]
		ifFalse: [ WriteStream on: (species new: stream sizeHint approximateAmount) ]
]

{ #category : #'private - streaming' }
AsyncStreamCollectFuture >> privateFinish [
	<return: #Collection>
	| aResultingCollection |
	
	aResultingCollection := (species inheritsFrom: HashedCollection)
		ifTrue: [ outputStream ]
		ifFalse: [
			outputStream position = outputStream originalContents size
				ifTrue: [ outputStream originalContents ]
				ifFalse: [ outputStream contents ] ].

	outputStream := nil.

	^ aResultingCollection
]

{ #category : #'private - streaming' }
AsyncStreamCollectFuture >> privateNextPut: anObject [
	(species inheritsFrom: HashedCollection)
		ifTrue: [ outputStream add: anObject ]
		ifFalse: [ outputStream nextPut: anObject ]
]

{ #category : #initialization }
AsyncStreamCollectFuture >> species: aClass [
	species := aClass
]

{ #category : #initialization }
AsyncStreamCollectFuture >> stream: anAsyncStream [
	stream := anAsyncStream
]
