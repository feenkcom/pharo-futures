Extension { #name : 'BlockClosure' }

{ #category : '*Futures' }
BlockClosure >> asFuture [
	^ AsyncPollFuture pollBlock: self
]
