Extension { #name : 'Object' }

{ #category : '*Futures' }
Object >> asFuture [
	^ AsyncReadyFuture value: self
]
