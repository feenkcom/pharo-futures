Extension { #name : #Exception }

{ #category : #'*Futures' }
Exception >> asAsyncPromise [
	^ AsyncRejectedPromise new error: self
]
