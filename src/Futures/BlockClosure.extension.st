Extension { #name : #BlockClosure }

{ #category : #'*Futures' }
BlockClosure >> asAsyncForkedFuture [
	^ AsyncForkPollFuture pollBlock: self
]

{ #category : #'*Futures' }
BlockClosure >> asAsyncFuture [
	^ AsyncPollFuture pollBlock: self
]

{ #category : #'*Futures' }
BlockClosure >> asAsyncPromise [
	^ self asAsyncFuture await
]

{ #category : #'*Futures' }
BlockClosure >> asAsyncPromiseWithLowPriority [
	^ self asAsyncFuture awaitWithLowPriority
]

{ #category : #'*Futures' }
BlockClosure >> entryPriority [
	"Answer the priority of the receiver when submitted as a task to TaskIt. 0 is highest priority"

	^0
]

{ #category : #'*Futures' }
BlockClosure >> valueWithoutTermination [
	"Evaluate the receiver ensuring that it can't be terminated by another process.
	This relies on the VM allowing #ensure: blocks to complete before continuing terminating the process."

	| result |

	[ ] ensure: [ result := self value ].
	^result
]

{ #category : #'*Futures' }
BlockClosure >> valueWithoutUserInterruption [
	"Evaluate the receiver (block), without the possibility of preemption by other normal user priority processes.
	This raises the priority to #userInterruptPriority+1 to prevent preemption by other user processes.  Processes such as those running at I/O or timing priority will still get priority"

	| activeProcess oldPriority result semaphore |

	activeProcess := Processor activeProcess.
	oldPriority := activeProcess priority.
	activeProcess priority: Processor userInterruptPriority + 1.
	result := self ensure: [activeProcess priority: oldPriority].
	
	"Yield after restoring priority to give the preempted processes a chance to run.
	We inline the code of Processor yield here, but without the primitive.
	The reason: the yield primitive does not take into account a change of priority as done above" 
	semaphore := Semaphore new.
	[semaphore signal] fork.
	semaphore wait.
	^result
]
