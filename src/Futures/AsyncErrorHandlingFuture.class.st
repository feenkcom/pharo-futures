"
An error handling future allows users to define an action to be executed in case of an error.
The provided error handling action is a {{gtClass:BlockClosure}} that accepts one argument - a subclass of {{gtClass:Exception}}. That exception object will contain a live execution stack which allows users to spawn a live debugger.
"
Class {
	#name : #AsyncErrorHandlingFuture,
	#superclass : #Object,
	#traits : 'TAsyncFuture',
	#classTraits : 'TAsyncFuture classTrait',
	#instVars : [
		'future',
		'errorBlock',
		'errorClass'
	],
	#category : #'Futures-Base - Futures'
}

{ #category : #'instance creation' }
AsyncErrorHandlingFuture class >> future: anAsyncFuture on: anException do: aHandlerAction [
	^ self new
		future: anAsyncFuture
		on: anException
		do: aHandlerAction
]

{ #category : #initialization }
AsyncErrorHandlingFuture >> future: anAsyncFuture on: anException do: aHandlerAction [
	future := anAsyncFuture.
	errorClass := anException.
	errorBlock := aHandlerAction
]

{ #category : #'api - future' }
AsyncErrorHandlingFuture >> poll: anAsynchronousContext [
	<return: #AsyncPoll>

	^ [ future poll: anAsynchronousContext ]
		on: errorClass
		do: errorBlock
]

{ #category : #'api - future copy' }
AsyncErrorHandlingFuture >> postSimilarCopy [
	"Is called by similarCopy. self is a shallow copy, implementors should set the fields as necessary to complete the similar copy"
	
	future := future asyncSimilarCopy
]
