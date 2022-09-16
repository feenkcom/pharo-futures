Class {
	#name : #AsyncErrorHandler,
	#superclass : #Object,
	#traits : 'TAsyncErrorHandler',
	#classTraits : 'TAsyncErrorHandler classTrait',
	#instVars : [
		'exception',
		'action'
	],
	#category : #'Futures-Error Handler'
}

{ #category : #'instance creation' }
AsyncErrorHandler class >> on: anException do: aHandlerAction [
	^ self new
		on: anException
		do: aHandlerAction
]

{ #category : #'error handling' }
AsyncErrorHandler >> handleError: anException [
	(exception handles: anException)
		ifTrue: [ action cull: anException ]
]

{ #category : #initialization }
AsyncErrorHandler >> on: anException do: aHandlerAction [
	exception := anException.
	action := aHandlerAction
]
