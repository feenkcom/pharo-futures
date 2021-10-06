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
	pollBlock := aBlock
]
