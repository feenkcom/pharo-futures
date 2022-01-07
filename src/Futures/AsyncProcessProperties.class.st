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

{ #category : #accessing }
AsyncProcessProperties class >> process: aProcess property: aPropertyKey ifAbsent: anAbsentBlock [
	^ (Properties
		at: aProcess
		ifAbsent: [ ^ anAbsentBlock ])
			at: aPropertyKey
			ifAbsent: anAbsentBlock
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
AsyncProcessProperties class >> workerOfProcess: aProcess ifAbsent: anAbsentBlock [
	^ self
		process: aProcess
		property: #worker
		ifAbsent: anAbsentBlock
]

{ #category : #'accessing - properties' }
AsyncProcessProperties class >> workerOfProcess: aProcess put: aProcessWorker [
	^ self
		process: aProcess
		property: #worker
		put: aProcessWorker
]
