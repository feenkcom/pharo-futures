Class {
	#name : #AsyncSemaphoreForMutualExclusion,
	#superclass : #Semaphore,
	#category : #'Futures-Utilities'
}

{ #category : #'instance creation' }
AsyncSemaphoreForMutualExclusion class >> forMutualExclusion [
	"Answer an instance of me that contains a single signal. This new
	instance can now be used for mutual exclusion (see the critical: message
	to Semaphore)."

	^ self new signal
]
