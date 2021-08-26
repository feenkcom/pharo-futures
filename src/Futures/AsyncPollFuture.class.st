Class {
	#name : 'AsyncPollFuture',
	#superclass : 'Object',
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'pollBlock'
	],
	#category : 'Futures-Future'
}

{ #category : 'instance creation' }
AsyncPollFuture class >> pollBlock: aBlock [
	^ self new pollBlock: aBlock
]

{ #category : 'api - future' }
AsyncPollFuture >> poll: anAsynchronousContext [
	^ AsyncPoll ready: (pollBlock cull: anAsynchronousContext)
]

{ #category : 'initialization' }
AsyncPollFuture >> pollBlock: anObject [

	pollBlock := anObject
]
