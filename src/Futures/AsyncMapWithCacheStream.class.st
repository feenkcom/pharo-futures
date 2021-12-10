"
#Caching map Stream
Similar to {{gtClass:AsyncMapStream}} with an ability to cache the mappings in a provided external dictionary.

##Example
{{gtExample:AsyncStreamExamples>>#mapCached}}
"
Class {
	#name : #AsyncMapWithCacheStream,
	#superclass : #Object,
	#traits : 'TAsyncStream',
	#classTraits : 'TAsyncStream classTrait',
	#instVars : [
		'stream',
		'cache',
		'mapBlock',
		'keyBlock'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncMapWithCacheStream class >> forStream: anAsyncStream map: aBlock cache: aSharedDictionary [
	^ self
		forStream: anAsyncStream
		map: aBlock
		key: [ :each | each ]
		cache: aSharedDictionary
]

{ #category : #'instance creation' }
AsyncMapWithCacheStream class >> forStream: anAsyncStream map: aBlock key: aKeyBlock cache: aSharedDictionary [
	^ self new
		stream: anAsyncStream
		map: aBlock
		key: aKeyBlock
		cache: aSharedDictionary
]

{ #category : #'api - stream' }
AsyncMapWithCacheStream >> pollNext: anAsynchronousContext [
	"Attempt to pull out the next value of this stream, registering the current task for wakeup if the value is not yet available, and returning None if the stream is exhausted.
	There are several possible return values, each indicating a distinct stream state:
	 - Poll::Pending means that this stream's next value is not ready yet. Implementations will ensure that the current task will be notified when the next value may be ready.
	 - Poll::Ready(Some(val)) means that the stream has successfully produced a value, val, and may produce further values on subsequent poll_next calls.
	 - Poll::Ready(None) means that the stream has terminated, and poll_next should not be invoked again."
	<return: #AsyncPoll>
	
	^ (stream pollNext: anAsynchronousContext)
		ifReady: [ :aReadyPoll |
			aReadyPoll value
				ifSome: [ :anItem |
					| aMappedValue |
					aMappedValue := cache
						at: (keyBlock value: anItem)
						ifAbsentPut: [ mapBlock value: anItem ].
					AsyncPoll ready: (AsyncOptionalValue some: aMappedValue)  ]
				ifNone: [ aReadyPoll ] ]
		ifPending: [ :aPendingPoll | aPendingPoll ]
]

{ #category : #'api - stream copy' }
AsyncMapWithCacheStream >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #initialization }
AsyncMapWithCacheStream >> stream: anAsyncStream map: aBlock key: aKeyBlock cache: aSharedDictionary [
	cache := aSharedDictionary.
	stream := anAsyncStream.
	mapBlock := aBlock.
	keyBlock := aKeyBlock
]
