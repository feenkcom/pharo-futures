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
	
	monitor := Monitor new
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
	"Acquire a lock for a duration of the block and initialize the locked value with an object provided by ifNilBlock.
	The value initialization happens before evaluating aBlock, therefore the lock: block is always executed with an non-nil object.
	This is like #critical: but releasing the lock if there is an exception in the block"
	| blockValue caught |

	caught := false.
	[
		caught := true.
		monitor enter.
		"The following prevents deadlocks in case of exceptions.
		Deadlock happens when a thread is suspended by the debugger and the semaphore is not signalled"
		value ifNil: [ value := ifNilBlock value ].
		blockValue := [ mutuallyExcludedBlock cull: value ]
			on: Exception 
			do: [ :anException |
				caught ifTrue: [ monitor exit ]. 
				caught := false.
				anException pass ].
	] ensure: [ caught ifTrue: [ monitor exit ] ].

	^ blockValue
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
AsyncMutex >> value: aValue [
	self lock: [ value := aValue ]
]
