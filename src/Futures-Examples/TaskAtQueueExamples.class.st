Class {
	#name : #TaskAtQueueExamples,
	#superclass : #Object,
	#traits : 'TAssertable',
	#classTraits : 'TAssertable classTrait',
	#category : #'Futures-Examples'
}

{ #category : #examples }
TaskAtQueueExamples >> checkQueueOrder [
	"Ensure that tasks are retrieved from the queue in chronological order"

	<gtExample>
	<return: #TaskAtQueueExamples>
	| queue now entries |
	queue := TaskAtQueue new.
	now := DateAndTime now.
	queue schedule: 1 at: now + 10 seconds.
	queue schedule: 5 at: now + 50 seconds.
	queue schedule: 3 at: now + 30 seconds.
	queue schedule: 7 at: now + 70 seconds.
	queue schedule: 2 at: now + 20 seconds.	"Set the queue process time so entryPriority can be calculated"
	queue processTime: now.

	entries := OrderedCollection new.
	5 timesRepeat: [ entries add: queue next valuable ].

	self assert: entries asArray equals: #(1 2 3 5 7)
]

{ #category : #examples }
TaskAtQueueExamples >> removeTask [
	"Demonstrate removing a task from the queue"

	<gtExample>
	<return: #TaskAtQueueExamples>
	| clock queue now task executed |
	executed := 0.
	clock := BlSimulatedTime new.
	queue := TaskAtQueue new clock: clock.
	now := clock currentTime.
	task := TaskAtQueueTask
			valuable: [ executed := executed + 1 ]
			at: now + 10 seconds
			entryIdentifier: self class name.
	queue schedule: task.
	self assert: executed equals: 0.

	queue pulse.
	self assert: executed equals: 0.

	queue removeTask: task.
	clock wait: 12 seconds.

	queue pulse.
	self assert: executed equals: 0
]

{ #category : #examples }
TaskAtQueueExamples >> rescheduleTaskBackward [
	"{{gtClass:BlTaskAtQueue}} allows tasks to be rescheduled, changing their time forwards or backwards.
	Demonstrate rescheduling tasks, changing it's time so that it is run earlier"

	<gtExample>
	<return: #TaskAtQueueExamples>
	| clock queue now task executed |
	executed := 0.
	clock := BlSimulatedTime new.
	queue := TaskAtQueue new clock: clock.
	now := clock currentTime.
	task := TaskAtQueueTask
			valuable: [ executed := executed + 1 ]
			at: now + 10 seconds
			entryIdentifier: self class name.
	queue schedule: task.
	self assert: executed equals: 0.

	clock wait: 2 seconds.
	queue pulse.
	self assert: executed equals: 0.

	task scheduledTime: now + 2 seconds.
	queue schedule: task.
	queue pulse.
	self assert: executed equals: 1
]

{ #category : #examples }
TaskAtQueueExamples >> rescheduleTaskForward [
	"{{gtClass:BlTaskAtQueue}} allows tasks to be rescheduled, changing their time forwards or backwards.
	Demonstrate rescheduling tasks, changing it's time so that it is run earlier"

	<gtExample>
	<return: #TaskAtQueueExamples>
	| clock queue now task executed |
	executed := 0.
	clock := BlSimulatedTime new.
	queue := TaskAtQueue new clock: clock.
	now := clock currentTime.
	task := TaskAtQueueTask
			valuable: [ executed := executed + 1 ]
			at: now + 10 seconds
			entryIdentifier: self class name.
	queue schedule: task.
	self assert: executed equals: 0.

	queue pulse.
	self assert: executed equals: 0.

	clock wait: 2 seconds.

	queue pulse.
	self assert: executed equals: 0.

	task scheduledTime: now + 1 second.
	queue schedule: task.
	queue pulse.
	self assert: executed equals: 1
]

{ #category : #examples }
TaskAtQueueExamples >> runNow [
	"Queue a task that has a scheduled time in the past."

	<gtExample>
	<return: #TaskAtQueueExamples>
	| queue taskRun |
	queue := self taskAtQueue.
	taskRun := false.
	queue schedule: [ taskRun := true ] at: self startTime.
	self assert: queue size equals: 1.
	queue processNextEntry.
	self assert: taskRun
]

{ #category : #examples }
TaskAtQueueExamples >> runOneInOneSecond [
	"Queue a task that has a scheduled time in the past."

	<gtExample>
	<return: #TaskAtQueueExamples>
	| queue taskRun currentTime |
	currentTime := self startTime.
	queue := self taskAtQueue.
	taskRun := false.
	queue schedule: [ taskRun := true ] at: self startTime + 1 second.
	self assert: queue size equals: 1.
	queue processNextEntry.
	self deny: taskRun.
	self assert: queue size equals: 1.
	queue clock date: (currentTime := currentTime + 1 second).
	queue pulse.
	self assert: taskRun
]

{ #category : #examples }
TaskAtQueueExamples >> runPastTime [
	"Queue a task that has a scheduled time in the past."

	<gtExample>
	<return: #TaskAtQueueExamples>
	| queue taskRun |
	queue := self taskAtQueue.
	taskRun := false.
	queue schedule: [ taskRun := true ] at: self startTime - 1 second.
	self assert: queue size equals: 1.
	queue processNextEntry.
	self assert: taskRun
]

{ #category : #examples }
TaskAtQueueExamples >> runTwoOneThree [
	"Queue three tasks, out of order, and confirm correct execution."

	<gtExample>
	<return: #TaskAtQueueExamples>
	| queue value currentTime |
	currentTime := self startTime.
	queue := self taskAtQueue.
	value := 0.
	queue schedule: [ value := 2 ] at: self startTime + 2 second.
	queue schedule: [ value := 1 ] at: self startTime + 1 second.
	queue schedule: [ value := 3 ] at: self startTime + 3 second.
	self assert: queue size equals: 3.
	queue processNextEntry.
	self assert: value equals: 0.
	queue clock date: (currentTime := currentTime + 1 second).
	queue pulse.
	self assert: value equals: 1.
	self assert: queue size equals: 2.
	queue clock date: (currentTime := currentTime + 1 second).
	queue pulse.
	self assert: value equals: 2.
	self assert: queue size equals: 1.
	queue clock date: (currentTime := currentTime + 1 second).
	queue pulse.
	self assert: value equals: 3.
	self assert: queue size equals: 0
]

{ #category : #private }
TaskAtQueueExamples >> startTime [

	^ DateAndTime fromString: '2020-11-07T12:19:53.275521+01:00'
]

{ #category : #private }
TaskAtQueueExamples >> taskAtQueue [
	"Answer the BlTaskAtQueue used for the examples.
	The queue is configured to use a simulated clock with a fixed current time for reproduceable tests."

	^ TaskAtQueue new 
		clock: (BlSimulatedTime new date: self startTime)
]
