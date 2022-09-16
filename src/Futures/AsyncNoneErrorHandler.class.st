Class {
	#name : #AsyncNoneErrorHandler,
	#superclass : #Object,
	#traits : 'TAsyncErrorHandler',
	#classTraits : 'TAsyncErrorHandler classTrait',
	#classInstVars : [
		'uniqueInstance'
	],
	#category : #'Futures-Error Handler'
}

{ #category : #accessing }
AsyncNoneErrorHandler class >> uniqueInstance [
	^ uniqueInstance ifNil: [ uniqueInstance := self new ]
]

{ #category : #'error handling' }
AsyncNoneErrorHandler >> handleError: anException [
]
