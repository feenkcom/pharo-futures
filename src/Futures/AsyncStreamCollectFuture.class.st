Class {
	#name : 'AsyncStreamCollectFuture',
	#superclass : 'Object',
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'species',
		'outputStream'
	],
	#category : 'Futures-Base - Futures'
}

{ #category : 'instance creation' }
AsyncStreamCollectFuture class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : 'instance creation' }
AsyncStreamCollectFuture class >> stream: anAsyncStream species: aClass [
	^ self new
		stream: anAsyncStream;
		species: aClass
]

{ #category : 'api - future' }
AsyncStreamCollectFuture >> finish [
	<return: #OrderedCollection>
	| aResultingCollection |
	
	aResultingCollection := outputStream position = outputStream originalContents size
		ifTrue: [ outputStream originalContents ]
		ifFalse: [ outputStream contents ].

	outputStream := nil.

	^ aResultingCollection
]

{ #category : 'initialization' }
AsyncStreamCollectFuture >> initialize [
	super initialize.
	
	species := Array.
	outputStream := nil
]

{ #category : 'api - future' }
AsyncStreamCollectFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	outputStream ifNil: [
		outputStream := WriteStream on: (species new: stream sizeHint approximateAmount) ].

	[ 
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :nextItem | outputStream nextPut: nextItem ]
					ifNone: [ ^ AsyncPoll ready: self finish ]
			]
			ifPending: [ :aPendingPoll | ^ aPendingPoll ]
	] repeat
]

{ #category : 'initialization' }
AsyncStreamCollectFuture >> species: aClass [
	species := aClass
]

{ #category : 'initialization' }
AsyncStreamCollectFuture >> stream: anAsyncStream [
	stream := anAsyncStream
]
