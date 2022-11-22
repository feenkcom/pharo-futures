Class {
	#name : #AsyncEphemeron,
	#superclass : #Ephemeron,
	#type : #ephemeron,
	#category : #'Futures-Utilities'
}

{ #category : #mourning }
AsyncEphemeron >> mourn [
	self value mourn.
	super mourn
]
