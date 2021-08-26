Class {
	#name : 'AsyncStreamCollectFuture',
	#superclass : 'Object',
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'collection'
	],
	#category : 'Futures-Future'
}

{ #category : 'instance creation' }
AsyncStreamCollectFuture class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : 'api - future' }
AsyncStreamCollectFuture >> finish [
	<return: #OrderedCollection>
	| aResultingCollection |
	
	aResultingCollection := collection.
	collection := OrderedCollection new.

	^ aResultingCollection
]

{ #category : 'initialization' }
AsyncStreamCollectFuture >> initialize [
	super initialize.
	
	collection := OrderedCollection new
]

{ #category : 'api - future' }
AsyncStreamCollectFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	[ 
		(stream pollNext: anAsynchronousContext)
			ifReady: [ :aReadyPoll |
				aReadyPoll value
					ifSome: [ :nextItem | collection add: nextItem ]
					ifNone: [ ^ AsyncPoll ready: self finish ]
			]
			ifPending: [ :aPendingPoll | ^ aPendingPoll ]
	] repeat
]

{ #category : 'initialization' }
AsyncStreamCollectFuture >> stream: anAsyncStream [
	stream := anAsyncStream
]
