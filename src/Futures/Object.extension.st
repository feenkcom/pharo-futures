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
Object >> asyncSimilarCopy [
	^ self
]

{ #category : #'*Futures' }
Object >> isAsyncFuture [
	^ false
]

{ #category : #'*Futures' }
Object >> isAsyncPromise [
	^ false
]

{ #category : #'*Futures' }
Object >> isAsyncStream [
	^ false
]
