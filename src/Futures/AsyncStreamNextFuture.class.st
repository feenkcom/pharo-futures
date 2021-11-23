"
A future that resolves to the next item in the stream.
"
Class {
	#name : #AsyncStreamNextFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'stream'
	],
	#category : #'Futures-Base - Streams'
}

{ #category : #'instance creation' }
AsyncStreamNextFuture class >> stream: anAsyncStream [
	^ self new stream: anAsyncStream
]

{ #category : #'api - future' }
AsyncStreamNextFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ stream pollNext: anAsynchronousContext
]

{ #category : #initialization }
AsyncStreamNextFuture >> stream: anAsyncStream [
	stream := anAsyncStream
]
