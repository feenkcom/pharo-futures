Class {
	#name : #AsyncPassExceptionHandler,
	#superclass : #Object,
	#traits : 'TAsyncErrorHandler',
	#classTraits : 'TAsyncErrorHandler classTrait',
	#category : #'Futures-Error Handler'
}

{ #category : #'error handling' }
AsyncPassExceptionHandler >> handleError: anException [
	anException pass
]
