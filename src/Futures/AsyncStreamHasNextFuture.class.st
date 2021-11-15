Class {
	#name : #AsyncStreamHasNextFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncStreamHasNextFuture class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'api - future' }
AsyncStreamHasNextFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ (stream pollNext: anAsynchronousContext) map: [ :aValueOption | aValueOption isSome ]
]

{ #category : #'api - future copy' }
AsyncStreamHasNextFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	stream := stream asyncSimilarCopy
]

{ #category : #initialization }
AsyncStreamHasNextFuture >> stream: anAsyncStream [
	stream := anAsyncStream
]
