Extension { #name : #Object }

{ #category : #'*Futures' }
Object >> asAsyncFuture [
	^ AsyncReadyFuture value: self
]

{ #category : #'*Futures' }
Object >> asAsyncPromise [
	^ AsyncFulfilledPromise new value: self
]

{ #category : #'*Futures' }
Object >> isAsyncPromise [
	^ false
]
