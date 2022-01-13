Class {
	#name : #AsyncErrorSafeOrderedCollection,
	#superclass : #OrderedCollection,
	#category : #'Futures-Collections'
}

{ #category : #accessing }
AsyncErrorSafeOrderedCollection >> do: aBlock [
	self do: aBlock startingAt: firstIndex
]

{ #category : #accessing }
AsyncErrorSafeOrderedCollection >> do: aBlock startingAt: startIndex [
	startIndex to: lastIndex do: [ :index | 
		[ aBlock value: (array at: index) ]
			ifCurtailed: [ self do: aBlock startingAt: index + 1 ] ]
]
