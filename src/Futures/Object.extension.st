Extension { #name : 'Object' }

{ #category : '*Futures' }
Object >> asFuturePoll [
	^ AsyncPoll ready: self
]

{ #category : '*Futures' }
Object >> gtFuture [
	^ AsyncReadyFuture value: self
]
