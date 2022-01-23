Class {
	#name : #AsyncCachedFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future',
		'cache'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncCachedFuture class >> forFuture: anAsyncFuture cache: anAsyncFutureCache [
	^ self new
		future: anAsyncFuture
		cache: anAsyncFutureCache
]

{ #category : #'instance creation' }
AsyncCachedFuture >> future: anAsyncFuture cache: anAsyncFutureCache [
	future := anAsyncFuture.
	cache := anAsyncFutureCache
]

{ #category : #'api - future' }
AsyncCachedFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ cache
		ifSome: [ :aValue | AsyncPoll ready: aValue ]
		ifNonePutPoll: [ future poll: anAsynchronousContext ]
]

{ #category : #'api - future copy' }
AsyncCachedFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy
]
