Class {
	#name : #AsyncTypedFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #testing }
AsyncTypedFuture class >> isAbstract [
	^ self = AsyncTypedFuture
]

{ #category : #accessing }
AsyncTypedFuture >> future: anObject [

	future := anObject
]

{ #category : #'api - future' }
AsyncTypedFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ future poll: anAsynchronousContext
]

{ #category : #'api - future copy' }
AsyncTypedFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy
]
