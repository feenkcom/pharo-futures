Extension { #name : #SequenceableCollection }

{ #category : #'*Futures' }
SequenceableCollection >> asAsyncStream [
	^ AsyncSequenceStream forCollection: self
]

{ #category : #'*Futures' }
SequenceableCollection >> asyncSimilarCopy [
	^ self collect: [ :each | each asyncSimilarCopy ]
]
