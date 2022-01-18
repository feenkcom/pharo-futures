"
#Shared OrderedCollection
Is a thread-safe {{gtClass:OrderedCollection}} that synchronises the api calls with the help of a {{gtClass:Monitor}}.
"
Class {
	#name : #AsyncSharedOrderedCollection,
	#superclass : #AsyncAbstractOrderedCollection,
	#category : #'Futures-Collections'
}

{ #category : #accessing }
AsyncSharedOrderedCollection class >> collectionType [
	^ OrderedCollection
]
