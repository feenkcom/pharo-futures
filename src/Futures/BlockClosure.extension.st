Extension { #name : #BlockClosure }

{ #category : #'*Futures' }
BlockClosure >> asAsyncFuture [
	^ AsyncPollFuture pollBlock: self
]

{ #category : #'*Futures' }
BlockClosure >> asAsyncPromise [
	^ AsyncFuturePromise new future: self asAsyncFuture
]
