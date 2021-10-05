Extension { #name : #SequenceableCollection }

{ #category : #'*Futures' }
SequenceableCollection >> asAsyncStream [
	^ AsyncSequenceStream forCollection: self
]
