Extension { #name : #OrderedCollection }

{ #category : #'*Futures' }
OrderedCollection >> asyncCollectorIndex: anIndex [
	"This method converts anIndex to an index in the range firstIndex .. lastIndex"
	
	^ firstIndex + anIndex - 1
]
