Class {
	#name : #AsyncSharedIdentityDictionary,
	#superclass : #AsyncSharedDictionary,
	#category : #'Futures-Collections - Dictionary'
}

{ #category : #initialization }
AsyncSharedIdentityDictionary >> newDictionary [
	^ IdentityDictionary new
]
