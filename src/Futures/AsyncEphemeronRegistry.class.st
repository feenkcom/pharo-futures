Class {
	#name : #AsyncEphemeronRegistry,
	#superclass : #EphemeronRegistry,
	#category : #'Futures-Utilities'
}

{ #category : #accessing }
AsyncEphemeronRegistry >> at: key put: value [
	^ self registerEphemeron: (AsyncEphemeron key: key value: value container: self)
]
