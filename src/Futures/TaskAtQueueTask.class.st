"
BlTaskAtTask is the object added to the queue by BlTaskAtQueue.  It stores the valuable and scheduled execution time.

## Internal Representation and Key Implementation Points.

### Instance Variables

	scheduledTime:		<DateAndTime>
	valuable:				<Object>


"
Class {
	#name : #TaskAtQueueTask,
	#superclass : #Object,
	#instVars : [
		'valuable',
		'scheduledTime',
		'queue',
		'entryIdentifier'
	],
	#category : #'Futures-Collections - Queue'
}

{ #category : #'instance creation' }
TaskAtQueueTask class >> valuable: aValuable at: aTime [

	^self new initialize: aValuable at: aTime
]

{ #category : #'instance creation' }
TaskAtQueueTask class >> valuable: aValuable at: aTime entryIdentifier: anObject [

	^self new initialize: aValuable at: aTime entryIdentifier: anObject
]

{ #category : #accessing }
TaskAtQueueTask >> entryIdentifier [
	"Answer the object used to identify the task"
	<return: #Object>

	^ entryIdentifier
]

{ #category : #accessing }
TaskAtQueueTask >> entryIdentifier: anObject [

	entryIdentifier := anObject
]

{ #category : #accessing }
TaskAtQueueTask >> entryPriority [ 
	"Answer the receiver's priority.
	0 is highest, so earlier scheduled tasks have a higher priority"

	^ (scheduledTime - queue processTime) asMilliSeconds max: 0

]

{ #category : #handling }
TaskAtQueueTask >> handleNotScheduledBecauseOfPreviousTask: aBlTaskAtTask [
	"subclasses can act on this event"
]

{ #category : #initialization }
TaskAtQueueTask >> initialize: aValuable at: aTime [

	valuable := aValuable.
	scheduledTime := aTime.
]

{ #category : #initialization }
TaskAtQueueTask >> initialize: aValuable at: aTime entryIdentifier: anObject [

	valuable := aValuable.
	scheduledTime := aTime.
	entryIdentifier := anObject.
]

{ #category : #printing }
TaskAtQueueTask >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '(';
		print: scheduledTime;
		<< ')'
]

{ #category : #accessing }
TaskAtQueueTask >> queue [
	^ queue
]

{ #category : #accessing }
TaskAtQueueTask >> queue: anObject [
	queue := anObject
]

{ #category : #accessing }
TaskAtQueueTask >> scheduledTime [
	<return: #DateAndTime>

	^ scheduledTime
]

{ #category : #accessing }
TaskAtQueueTask >> scheduledTime: aDateAndTime [

	scheduledTime := aDateAndTime
]

{ #category : #accessing }
TaskAtQueueTask >> valuable [
	^ valuable
]

{ #category : #evaluating }
TaskAtQueueTask >> value [
	"evaluate valuable"
	^ self valuable value
]
