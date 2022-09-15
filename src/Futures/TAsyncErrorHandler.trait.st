Trait {
	#name : #TAsyncErrorHandler,
	#category : #'Futures-Error Handler'
}

{ #category : #'error handling' }
TAsyncErrorHandler >> handleError: anException [
	self explicitRequirement
]
