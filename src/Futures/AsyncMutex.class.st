Class {
	#name : #AsyncMutex,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'value'
	],
	#category : #'Futures-Collections - Value'
}

{ #category : #'instance creation' }
AsyncMutex class >> for: anObject [
	^ self new value: anObject
]

{ #category : #initialization }
AsyncMutex >> initialize [
	super initialize.
	
	monitor := Mutex new
]

{ #category : #'api - monitor' }
AsyncMutex >> lock: mutuallyExcludedBlock [
	"Acquire a lock for a duration of the mutuallyExcludedBlock."

	^ self
		lock: mutuallyExcludedBlock
		ifNilPut: [ value ]
]

{ #category : #'api - monitor' }
AsyncMutex >> lock: mutuallyExcludedBlock ifNilPut: ifNilBlock [
	"Acquire the lock, initialize the value if nil, and evaluate mutuallyExcludedBlock.
	Release the lock on an exception from either block."

	^ monitor criticalReleasingOnError: [
		value ifNil: [ value := ifNilBlock value ].
		mutuallyExcludedBlock cull: value ]
]

{ #category : #printing }
AsyncMutex >> printOn: aStream [
	aStream
		nextPutAll: self class name;
		space;
		nextPut: $(.
		
	self lock: [ :aValue | aStream print: aValue ].
	
	aStream nextPut: $)
]

{ #category : #'api - monitor' }
AsyncMutex >> value [
	^ self lock: [ :aValue | aValue ]
]

{ #category : #'api - monitor' }
AsyncMutex >> value: aValue [
	self lock: [ value := aValue ]
]
