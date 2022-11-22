Class {
	#name : #AsyncEphemeronRegistry,
	#superclass : #Object,
	#instVars : [
		'ephemeronCollection'
	],
	#category : #'Futures-Utilities'
}

{ #category : #accessing }
AsyncEphemeronRegistry >> at: key put: value [
	^ self registerEphemeron: (AsyncEphemeron key: key value: value container: self)
]

{ #category : #initialization }
AsyncEphemeronRegistry >> initialize [
	super initialize.
	
	ephemeronCollection := AsyncMutex for: IdentitySet new
]

{ #category : #testing }
AsyncEphemeronRegistry >> isEmpty [
	^ ephemeronCollection lock: [ :aCollection | aCollection isEmpty ]
]

{ #category : #registration }
AsyncEphemeronRegistry >> registerEphemeron: anEphemeron [
	^ ephemeronCollection lock: [ :aSet | aSet add: anEphemeron ]
]

{ #category : #registration }
AsyncEphemeronRegistry >> removeEphemeron: anEphemeron [
	ephemeronCollection lock: [ :aSet | aSet remove: anEphemeron ifAbsent: [  ] ]
]

{ #category : #accessing }
AsyncEphemeronRegistry >> size [
	^ ephemeronCollection lock: [ :aSet | aSet size ]
]
