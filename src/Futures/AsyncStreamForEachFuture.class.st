"
#Stream's forEach Future
Runs a {{gtClass:TAsyncStream}} to completion, executing the provided asynchronous closure for each element on the stream. The closure provided will be called for each item a stream produces, yielding a future. That future will then be executed to completion before moving on to the next item. The returned value is a {{gtClass:TAsyncFuture}} where the `Output` type is `true`; it is executed entirely for its side effects.

##Example

{{gtExample:AsyncStreamExamples>>#forEach}}
"
Class {
	#name : #AsyncStreamForEachFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream',
		'block',
		'future'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncStreamForEachFuture class >> forStream: anAsyncStream block: aBlock [
	^ self new stream: anAsyncStream block: aBlock
]

{ #category : #'api - future' }
AsyncStreamForEachFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	[ 
		future
			ifSome: [ :aFuture |
				(aFuture poll: anAsynchronousContext)
					ifReady: [ future := AsyncOptionalValue none ]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ] ]
			ifNone: [
				(stream pollNext: anAsynchronousContext)
					ifReady: [ :aReadyPoll |
						aReadyPoll value
							ifSome: [ :aNextValue | future := AsyncOptionalValue some: (block value: aNextValue) asAsyncFuture ]
							ifNone: [ ^ AsyncPoll ready: true ]
					]
					ifPending: [ :aPendingPoll | ^ aPendingPoll ]
			]
	] repeat
]

{ #category : #'api - future copy' }
AsyncStreamForEachFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy.
	future := AsyncOptionalValue none
]

{ #category : #initialization }
AsyncStreamForEachFuture >> stream: anAsyncStream block: aBlock [
	stream := anAsyncStream.
	block := aBlock.
	future := AsyncOptionalValue none
]
