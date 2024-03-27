Class {
	#name : #AsyncInformExceptionHandler,
	#superclass : #Object,
	#traits : 'TAsyncErrorHandler',
	#classTraits : 'TAsyncErrorHandler classTrait',
	#category : #'Futures-Error Handler'
}

{ #category : #'error handling' }
AsyncInformExceptionHandler >> handleError: anException [
	(anException isKindOf: AsyncFutureCancelled)
		ifTrue: [ ^ self ].

	GtObjectNotificationMessage new
		message: anException description;
		tooltip: 'Inspect error';
		object: anException copy freeze;
		registerNotifications
]
