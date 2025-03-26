"
BlTaskAtQueue provides a reasonably efficient mechanism to scheduled tasks to be executed at a specified time.

The queue executes tasks within a single pharo process at #userSchedulingPriority, so tasks should be kept as short as possible, typically queueing the task up at a more appropriate place, e.g. one of the TaskIt background queues or within the UI process.


## Public API and Key Messages

- start : 	Start the reader process 
- stop : 		Stop the reader process
- schedule:at: 	Schedule the supplied valuable to be executed at the specified time

 
## Internal Representation and Key Implementation Points.

### Instance Variables

	executorProcess:		<Process>
	queue:						<SharedPriorityUniqueQueue>
	scheduleSemaphore:		<Semaphore>
	processTime: 			<DateAndTime>


### Implementation Points

- Assumes that there is only one reader of the queue.
- processTime holds the current DateAndTime for the evaluation cycle.  Since {{gtClass:name=BlTaskAtQueueTask}}s use the time to calculate their entry priority this significantly reduces the number of times that the VM is called to retrieve the time.

"
Class {
	#name : #TaskAtQueue,
	#superclass : #Object,
	#instVars : [
		'queue',
		'scheduleSemaphore',
		'executorProcess',
		'nextTimeDelay',
		'cutoffDuration',
		'clock',
		'processTime'
	],
	#classVars : [
		'Default'
	],
	#category : #'Futures-Collections - Queue'
}

{ #category : #accessing }
TaskAtQueue class >> default [ 

	^Default ifNil: [ Default := self new start ]
]

{ #category : #'instance creation' }
TaskAtQueue class >> schedule: aValuable [

	^ self default schedule: aValuable
]

{ #category : #'instance creation' }
TaskAtQueue class >> schedule: aValuable at: aTime [

	^ self default schedule: aValuable at: aTime
]

{ #category : #'instance creation' }
TaskAtQueue class >> schedule: aValuable at: aTime entryIdentifier: anObject [

	^ self default schedule: aValuable at: aTime entryIdentifier: anObject
]

{ #category : #accessing }
TaskAtQueue >> clock [
	"Answer the clock used to schedule the receiver"

	^ clock
]

{ #category : #'private - accessing' }
TaskAtQueue >> clock: aClock [
	"Set the clock used to schedule the receiver.
	This is normally only changed for testing purposes."

	clock := aClock
]

{ #category : #accessing }
TaskAtQueue >> cutoffDuration [
	"Answer the duration used to determine whether to execute a task.
	I.e. tasks scheduled for less than cutoffDuration from now are run."
	<return: #Duration>

	^ cutoffDuration
]

{ #category : #accessing }
TaskAtQueue >> cutoffDuration: anObject [
	cutoffDuration := anObject
]

{ #category : #private }
TaskAtQueue >> forkExecutorProcess [

	self
		assert: [ executorProcess isNil ]
		description: [ 'Only one executor process is allowed' ].

	executorProcess := [ self queueReaderLoop ]
		forkAt: Processor userSchedulingPriority 
		named: 'BlTaskAtQueue Executor'.
]

{ #category : #initialization }
TaskAtQueue >> initialize [
	super initialize.

	queue := SharedPriorityUniqueQueue new.
	scheduleSemaphore := Semaphore new.
	cutoffDuration := 10 milliSeconds.
	nextTimeDelay := 15 seconds.
	clock := DateAndTime
]

{ #category : #private }
TaskAtQueue >> next [
	"Answer the next item from the receiver's queue.
	For testing purposes only."

	^queue next
]

{ #category : #private }
TaskAtQueue >> processNextEntry [
	| entry timeRemaining |

	scheduleSemaphore waitTimeoutMSecs: nextTimeDelay asMilliSeconds .
	processTime := clock now.
	[ entry := queue nextOrNilSuchThat: [ :anEntry |
			timeRemaining := anEntry scheduledTime - processTime.
			timeRemaining < cutoffDuration ] ] whileNotNil: 
		[ [ [ entry value ]
			on: Error 
			do: [ :ex |				
				TaskAtErrorSignal new 
					exception: ex;
					task: entry;
					message: 'Entry execution exception - continuing';
					emit ] ]
			on: Exception
			fork: [ :anException | anException pass ].
		processTime := clock now ].
	entry := queue peek.
	nextTimeDelay := entry 
		ifNil: [ 1 hour ]
		ifNotNil: [ entry scheduledTime - clock now ]
]

{ #category : #accessing }
TaskAtQueue >> processTime [
	"Answer the time that should be used for determining task priority and whether the task should be run now"
	<return: #DateAndTime>

	^ processTime
]

{ #category : #'private - accessing' }
TaskAtQueue >> processTime: aDateAndTime [
	"Set the time for processing the current entry.
	This is only used for testing."

	processTime := aDateAndTime.
]

{ #category : #'api - queue' }
TaskAtQueue >> pulse [
	"Try to run the next task if the time have arrived"
	
	scheduleSemaphore signal.
	self processNextEntry
]

{ #category : #private }
TaskAtQueue >> queueReaderLoop [
	"Prevent users from interrupting the process executing this loop"
	#GlutinIgnoreDuringInterruptStatus asClassIfPresent: [ :aClass |
		aClass value: true ].
	
	[
		[
			[ self processNextEntry ]
				on: Error 
				do: [ :anError |
					TaskAtErrorSignal new 
						exception: anError;
						message: 'Reader loop error - restarting';
						emit.
					(Delay forSeconds: 5) wait ]
		]
		on: Exception
		fork: [ :anException | anException pass ]

	] repeat
]

{ #category : #operations }
TaskAtQueue >> removeTask: aTaskAtTask [
	"Remove the supplied task from the queue.
	Return quietly if the task wasn't in the queue."

	queue nextOrNilSuchThat: [ :each | each == aTaskAtTask ]
]

{ #category : #operations }
TaskAtQueue >> schedule: aTaskAtTask [
	"Add the supplied task to the queue and trigger the semaphore (which will either run the task immediately, or update the timeout, if required).
	Return the scheduled task or a similar previously scheduled task."
	| aResult |

	aTaskAtTask queue: self.
	aResult := queue nextPut: aTaskAtTask.
	aResult == aTaskAtTask ifFalse: [ 
		aTaskAtTask handleNotScheduledBecauseOfPreviousTask: aResult.
		^ aResult ].
	scheduleSemaphore signal.
	^ aTaskAtTask.
]

{ #category : #'api - queue' }
TaskAtQueue >> schedule: aValuable at: aTime [
	"Add the supplied task to the queue and trigger the semaphore at the appropriate time"

	self schedule: (TaskAtQueueTask valuable: aValuable at: aTime)
]

{ #category : #operations }
TaskAtQueue >> schedule: aValuable at: aTime entryIdentifier: anObject [
	"Add the supplied task to the queue and trigger the semaphore at the appropriate time"

	self schedule: (TaskAtQueueTask 
		valuable: aValuable 
		at: aTime
		entryIdentifier: anObject)
]

{ #category : #accessing }
TaskAtQueue >> size [

	^ queue size
]

{ #category : #control }
TaskAtQueue >> start [ 

	self forkExecutorProcess.
]

{ #category : #control }
TaskAtQueue >> stop [ 

	executorProcess ifNil: [ ^self ].
	executorProcess terminate.
	executorProcess := nil.
]
