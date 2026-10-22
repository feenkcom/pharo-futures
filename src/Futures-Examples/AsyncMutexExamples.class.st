"
Executable examples of AsyncMutex value access, lazy initialization, reentrancy, mutual exclusion, and exception release. Cross-process checks use bounded waits and clean up their worker processes. Resumable-exception examples document that execution resumes without reacquiring the lock.
"
Class {
	#name : #AsyncMutexExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #private }
AsyncMutexExamples >> assert: aMutex canBeLockedFromAnotherProcessWithValue: expectedValue [
	| done worker result failure |
	done := Semaphore new.
	worker := [
		[
			[ result := aMutex lock: [ :value | value ] ]
				on: Error
				do: [ :error | failure := error ]
		] ensure: [ done signal ]
	] fork.
	[
		self assert: (done waitTimeoutSeconds: 5) not.
		self assert: failure isNil.
		self assert: result equals: expectedValue
	] ensure: [ worker terminate ]
]

{ #category : #examples }
AsyncMutexExamples >> concurrentUpdates [
	<gtExample>
	<return: #AsyncMutex>
	| mutex done workers failures workerCount updatesPerWorker |
	mutex := AsyncMutex for: 0.
	done := Semaphore new.
	workerCount := 4.
	updatesPerWorker := 100.
	failures := Array new: workerCount.
	workers := OrderedCollection new.
	[
		1 to: workerCount do: [ :index |
			workers add: [
				[
					[ updatesPerWorker timesRepeat: [
						mutex lock: [ :value |
							"Force contention between reading and writing the value."
							Processor yield.
							mutex value: value + 1 ] ] ]
						on: Error
						do: [ :error | failures at: index put: error ]
				] ensure: [ done signal ]
			] fork ].
		workerCount timesRepeat: [
			self assert: (done waitTimeoutSeconds: 5) not ].
		self assert: (failures allSatisfy: #isNil).
		self assert: mutex value equals: workerCount * updatesPerWorker
	] ensure: [ workers do: #terminate ].
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> emptyMutex [
	<gtExample>
	<return: #AsyncMutex>
	| mutex |
	mutex := AsyncMutex new.
	self assert: mutex value isNil.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> errorInInitializerReleasesLock [
	<gtExample>
	<return: #AsyncMutex>
	| mutex handled bodyEvaluated |
	mutex := self emptyMutex.
	handled := false.
	bodyEvaluated := false.
	[ mutex
		lock: [ bodyEvaluated := true ]
		ifNilPut: [ Error signal: 'Expected initializer failure' ] ]
		on: Error
		do: [ :error |
			handled := true.
			self assert: error messageText equals: 'Expected initializer failure'.
			"Initialization has failed, and another process can enter before unwind."
			self assert: mutex canBeLockedFromAnotherProcessWithValue: nil ].
	self assert: handled.
	self assert: bodyEvaluated not.
	self assert: (mutex lock: [ :value | value ] ifNilPut: [ 42 ]) equals: 42.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> errorInLockedBlockReleasesLock [
	<gtExample>
	<return: #AsyncMutex>
	| mutex handled |
	mutex := AsyncMutex for: 42.
	handled := false.
	[ mutex lock: [ Error signal: 'Expected locked block failure' ] ]
		on: Error
		do: [ :error |
			handled := true.
			"Check before unwinding the failing lock: invocation."
			self assert: error messageText equals: 'Expected locked block failure'.
			self assert: mutex canBeLockedFromAnotherProcessWithValue: 42 ].
	self assert: handled.
	self assert: mutex canBeLockedFromAnotherProcessWithValue: 42.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> lazyInitialization [
	<gtExample>
	<return: #AsyncMutex>
	| mutex initializations result |
	mutex := self emptyMutex.
	initializations := 0.
	result := mutex
		lock: [ :value | value + 1 ]
		ifNilPut: [ initializations := initializations + 1. 41 ].
	self assert: result equals: 42.
	self assert: mutex value equals: 41.
	mutex
		lock: [ :value | self assert: value equals: 41 ]
		ifNilPut: [ initializations := initializations + 1. 99 ].
	self assert: initializations equals: 1.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> lockAnswersBlockResult [
	<gtExample>
	<return: #AsyncMutex>
	| mutex |
	mutex := AsyncMutex for: 41.
	self assert: (mutex lock: [ :value | value + 1 ]) equals: 42.
	self assert: (mutex lock: [ #withoutArguments ]) equals: #withoutArguments.
	self assert: mutex value equals: 41.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> mutexWithValue [
	<gtExample>
	<return: #AsyncMutex>
	| mutex |
	mutex := AsyncMutex for: 42.
	self assert: mutex value equals: 42.
	mutex value: 43.
	self assert: mutex value equals: 43.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> nilInitializationIsRetried [
	<gtExample>
	<return: #AsyncMutex>
	| mutex initializations |
	mutex := self emptyMutex.
	initializations := 0.
	self assert: (mutex
		lock: [ :value | value ]
		ifNilPut: [ initializations := initializations + 1. nil ]) isNil.
	self assert: (mutex
		lock: [ :value | value ]
		ifNilPut: [ initializations := initializations + 1. 42 ]) equals: 42.
	self assert: initializations equals: 2.
	self assert: mutex value equals: 42.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> nonLocalReturnReleasesLock [
	<gtExample>
	<return: #AsyncMutex>
	| mutex |
	mutex := AsyncMutex for: 41.
	self assert: (self returnFromLock: mutex) equals: 42.
	self assert: mutex canBeLockedFromAnotherProcessWithValue: 41.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> reentrantLock [
	<gtExample>
	<return: #AsyncMutex>
	| mutex result |
	mutex := AsyncMutex for: 41.
	result := mutex lock: [ :value |
		mutex value: value + 1.
		mutex lock: [ :nestedValue | nestedValue + 1 ] ].
	self assert: result equals: 43.
	self assert: mutex value equals: 42.
	self assert: mutex canBeLockedFromAnotherProcessWithValue: 42.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> resumingInitializerException [
	<gtExample>
	<return: #AsyncMutex>
	| mutex handled result |
	mutex := self emptyMutex.
	handled := false.
	"Resuming does not reacquire the lock released by the notification."
	result := [ mutex
		lock: [ :value | value + 1 ]
		ifNilPut: [ Notification signal: 'Expected initializer notification'. 41 ] ]
		on: Notification
		do: [ :notification |
			handled := true.
			self assert: mutex canBeLockedFromAnotherProcessWithValue: nil.
			notification resume ].
	self assert: handled.
	self assert: result equals: 42.
	self assert: mutex value equals: 41.
	^ mutex
]

{ #category : #examples }
AsyncMutexExamples >> resumingLockedBlockException [
	<gtExample>
	<return: #AsyncMutex>
	| mutex handled result |
	mutex := AsyncMutex for: 41.
	handled := false.
	"Another process may enter while an external handler is running."
	result := [ mutex lock: [ :value |
		Notification signal: 'Expected locked block notification'.
		value + 1 ] ]
		on: Notification
		do: [ :notification |
			handled := true.
			self assert: mutex canBeLockedFromAnotherProcessWithValue: 41.
			notification resume ].
	self assert: handled.
	self assert: result equals: 42.
	self assert: mutex value equals: 41.
	^ mutex
]

{ #category : #private }
AsyncMutexExamples >> returnFromLock: aMutex [
	aMutex lock: [ :value | ^ value + 1 ]
]
