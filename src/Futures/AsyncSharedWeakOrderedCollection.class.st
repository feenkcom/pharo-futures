Class {
	#name : #AsyncSharedWeakOrderedCollection,
	#superclass : #AsyncAbstractOrderedCollection,
	#category : #'Futures-Collections'
}

{ #category : #accessing }
AsyncSharedWeakOrderedCollection class >> collectionType [
	^ WeakOrderedCollection
]
