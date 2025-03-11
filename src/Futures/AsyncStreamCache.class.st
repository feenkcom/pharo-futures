"
#Stream cache
Is used by {{gtClass:AsyncCachedStream}} and is responsible for storing polled items in a cache collection and providing access to the cache by index. If a requested item is not yet available, polls it from an underlying stream.
"
Class {
	#name : #AsyncStreamCache,
	#superclass : #Object,
	#instVars : [
		'mutex',
		'stream',
		'items',
		'isDone'
	],
	#category : #'Futures-Utilities'
}

{ #category : #'instance creation' }
AsyncStreamCache class >> forStream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #initialization }
AsyncStreamCache >> initialize [
	super initialize.
	
	mutex := Monitor new.
]

{ #category : #'api - stream' }
AsyncStreamCache >> pollAt: anIndex context: anAsynchronousContext [
	<return: #AsyncPoll>

	[
		mutex critical: [
			anIndex > items size
				"Asked for an item outside of the cache"
				ifTrue: [
					isDone
						"we are done, there is nothing else to poll"
						ifTrue: [ ^ AsyncPoll ready: AsyncOptionalValue none ]
						ifFalse: [
							(stream pollNext: anAsynchronousContext)
								ifReady: [ :aReadyPoll |
									aReadyPoll value
										ifSome: [ :aNextItem | items add: aNextItem ]
										ifNone: [ isDone := true ].
									
									anIndex = items size
										"we just polled an item we were waiting for, return it"
										ifTrue: [ ^ aReadyPoll ] ]
								ifPending: [ :aPendingPoll | ^ aPendingPoll ] ] ]
				"an item is cached, we are good"
				ifFalse: [ ^ AsyncPoll ready: (AsyncOptionalValue some: (items at: anIndex)) ]
		]
	] repeat
]

{ #category : #accessing }
AsyncStreamCache >> stream [
	^ stream
]

{ #category : #initialization }
AsyncStreamCache >> stream: anAsyncStream [
	stream := anAsyncStream.
	items := OrderedCollection new.
	isDone := false
]
