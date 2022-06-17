Class {
	#name : #AsyncSharedWeakOrderedCollection,
	#superclass : #AsyncAbstractOrderedCollection,
	#category : #'Futures-Collections - Ordered Collection'
}

{ #category : #accessing }
AsyncSharedWeakOrderedCollection class >> collectionType [
	^ WeakOrderedCollection
]
