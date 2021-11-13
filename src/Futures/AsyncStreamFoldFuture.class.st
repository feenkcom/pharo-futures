Class {
	#name : #AsyncStreamFoldFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'block',
		'accumulator',
		'future'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncStreamFoldFuture class >> forStream: anAsyncStream initialValue: aValue block: aBlockClosure [
	^ self new stream: anAsyncStream initialValue: aValue block: aBlockClosure
]

{ #category : #'api - future' }
AsyncStreamFoldFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	[
		future
			ifSome: [ :aFuture |
				(aFuture poll: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						accumulator := AsyncOptionalValue some: aReadyPoll value.
						future := AsyncOptionalValue none
					]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ].
			]
			ifNone: [
				accumulator
					ifSome: [ :aCurrentAccumulatedValue |
						| aNextItemOption |
				
						aNextItemOption := (stream pollNext: anAsynchronousContext)
							ifReady: [ :aReadyPoll | aReadyPoll value ]
							ifPending: [ :aPendingPoll | ^ aPendingPoll ].
						
						aNextItemOption
							ifSome: [ :aNextItem |
								future := AsyncOptionalValue some: (block value: aCurrentAccumulatedValue value: aNextItem) asAsyncFuture ]
							ifNone: [ ^ AsyncPoll ready: aCurrentAccumulatedValue ]
							]
					ifNone: [ self error: 'Fold polled after completion' ].
			]
	] repeat
]

{ #category : #initialization }
AsyncStreamFoldFuture >> stream: anAsyncStream initialValue: aValue block: aBlockClosure [
	stream := anAsyncStream.
	accumulator := AsyncOptionalValue some: aValue.
	block := aBlockClosure.
	future := AsyncOptionalValue none
]
