Extension { #name : 'BlockClosure' }

{ #category : '*Futures' }
BlockClosure >> gtFuture [
	^ AsyncPollFuture pollBlock: self
]
