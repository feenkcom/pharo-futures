Class {
	#name : #AsyncProcessProperties,
	#superclass : #Object,
	#classVars : [
		'Properties'
	],
	#category : #'Futures-Utilities'
}

{ #category : #initialization }
AsyncProcessProperties class >> initialize [
	Properties := AsyncSharedWeakIdentityKeyDictionary new
]

{ #category : #testing }
AsyncProcessProperties class >> isWorkerProcess: aPharoProcess [
	^ (self
   	reifiedProcess: aPharoProcess
   	ifAbsent: [ nil ]) notNil
]

{ #category : #accessing }
AsyncProcessProperties class >> process: aProcess property: aPropertyKey ifAbsent: anAbsentBlock [
	^ (Properties
		at: aProcess
		ifAbsent: [ ^ anAbsentBlock value ])
			at: aPropertyKey
			ifAbsent: anAbsentBlock
]

{ #category : #accessing }
AsyncProcessProperties class >> process: aProcess property: aPropertyKey ifPresent: aPresentBlock [
	^ (Properties
		at: aProcess
		ifAbsent: [ ^ nil ])
			at: aPropertyKey
			ifPresent: aPresentBlock
]

{ #category : #accessing }
AsyncProcessProperties class >> process: aProcess property: aPropertyKey put: aPropertyValue [
	^ (Properties
		at: aProcess
		ifAbsentPut: [ AsyncSharedDictionary new ])
			at: aPropertyKey
			put: aPropertyValue
]

{ #category : #'accessing - properties' }
AsyncProcessProperties class >> reifiedProcess: aProcess ifAbsent: anAbsentBlock [
	^ self
		process: aProcess
		property: #reifiedProcess
		ifAbsent: anAbsentBlock
]

{ #category : #'accessing - properties' }
AsyncProcessProperties class >> reifyProcess: aProcess as: aProcessWorker [
	^ self
		process: aProcess
		property: #reifiedProcess
		put: aProcessWorker
]
