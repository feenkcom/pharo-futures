Class {
	#name : #AsyncDeadlockSafeMonitor,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'value'
	],
	#category : #'Futures-Collections - Value'
}

{ #category : #'api - monitor' }
AsyncDeadlockSafeMonitor >> critical: mutuallyExcludedBlock [
	"This is like #critical: but releasing the lock if there is an exception in the block"
	| blockValue caught |

	caught := false.
	[
		caught := true.
		monitor enter.
		"The following prevents deadlocks in case of exceptions.
		Deadlock happens when a thread is suspended by the debugger and the semaphore is not signalled"
		blockValue := [ mutuallyExcludedBlock value ]
			on: Exception 
			do: [ :anException |
				caught ifTrue: [ monitor exit ]. 
				caught := false.
				anException pass ].
	] ensure: [ caught ifTrue: [ monitor exit ] ].

	^ blockValue
]

{ #category : #initialization }
AsyncDeadlockSafeMonitor >> initialize [
	super initialize.
	
	monitor := Monitor new
]
