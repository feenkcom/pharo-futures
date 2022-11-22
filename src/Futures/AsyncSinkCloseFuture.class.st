"
#Close Sink Future
Closes a {{gtClass:TAsyncSink}} which ultimately results in sending {{gtMethod:TAsyncSink>>#pollClose:}}.
"
Class {
	#name : #AsyncSinkCloseFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'sink'
	],
	#category : #'Futures-Base - Sinks'
}

{ #category : #'instance creation' }
AsyncSinkCloseFuture class >> forSink: anAsyncSink [
	^ self new sink: anAsyncSink
]

{ #category : #'api - future' }
AsyncSinkCloseFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ sink pollClose: anAsynchronousContext
]

{ #category : #initialize }
AsyncSinkCloseFuture >> sink: anAsyncSink [
	sink := anAsyncSink.
	sink parentSink: self
]
