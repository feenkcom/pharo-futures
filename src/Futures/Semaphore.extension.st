Extension { #name : #Semaphore }

{ #category : #'*Futures' }
Semaphore class >> forMutualExclusion [
	"Answer an instance of me that contains a single signal. This new
	instance can now be used for mutual exclusion (see the critical: message
	to Semaphore)."

	^ AsyncSemaphoreForMutualExclusion new signal
]
