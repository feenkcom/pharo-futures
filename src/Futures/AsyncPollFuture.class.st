Class {
	#name : #AsyncPollFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'pollBlock',
		'executedBlock'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncPollFuture class >> pollBlock: aBlock [
	^ self new pollBlock: aBlock
]

{ #category : #printing }
AsyncPollFuture >> gtDisplayOn: aStream [
	super gtDisplayOn: aStream.
	aStream nextPut: $(.
	executedBlock
		ifNotNil: [ aStream nextPutAll: 'Executed' ]
		ifNil: [ aStream nextPutAll: 'Pending' ].
	aStream nextPut: $)
]

{ #category : #'api - future' }
AsyncPollFuture >> poll: anAsynchronousContext [
	self
		assert: [ pollBlock notNil ]
		description: [ 'Block already polled' ].

	executedBlock := pollBlock.
	pollBlock := nil.

	^ AsyncPoll ready: (executedBlock cull: anAsynchronousContext)
]

{ #category : #initialization }
AsyncPollFuture >> pollBlock: aBlock [
	pollBlock := aBlock.
	executedBlock := nil
]

{ #category : #'api - future copy' }
AsyncPollFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"

	executedBlock ifNotNil: [ pollBlock := executedBlock ].
	executedBlock := nil
]
