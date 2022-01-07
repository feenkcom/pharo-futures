"
BlTaskAtTask is the object added to the queue by BlTaskAtQueue.  It stores the valuable and scheduled execution time.

## Internal Representation and Key Implementation Points.

### Instance Variables

	scheduledTime:		<DateAndTime>
	valuable:				<Object>


"
Class {
	#name : #BlTaskAtQueueTask,
	#superclass : #Object,
	#instVars : [
		'valuable',
		'scheduledTime',
		'queue',
		'entryIdentifier'
	],
	#category : #'Futures-Collections'
}

{ #category : #'instance creation' }
BlTaskAtQueueTask class >> valuable: aValuable at: aTime [

	^self new initialize: aValuable at: aTime
]

{ #category : #'instance creation' }
BlTaskAtQueueTask class >> valuable: aValuable at: aTime entryIdentifier: anObject [

	^self new initialize: aValuable at: aTime entryIdentifier: anObject
]

{ #category : #accessing }
BlTaskAtQueueTask >> entryIdentifier [
	"Answer the object used to identify the task"
	<return: #Object>

	^ entryIdentifier
]

{ #category : #accessing }
BlTaskAtQueueTask >> entryIdentifier: anObject [

	entryIdentifier := anObject
]

{ #category : #accessing }
BlTaskAtQueueTask >> entryPriority [ 
	"Answer the receiver's priority.
	0 is highest, so earlier scheduled tasks have a higher priority"

	^ (scheduledTime - queue processTime) asMilliSeconds max: 0

]

{ #category : #handling }
BlTaskAtQueueTask >> handleNotScheduledBecauseOfPreviousTask: aBlTaskAtTask [
	"subclasses can act on this event"
]

{ #category : #initialization }
BlTaskAtQueueTask >> initialize: aValuable at: aTime [

	valuable := aValuable.
	scheduledTime := aTime.
]

{ #category : #initialization }
BlTaskAtQueueTask >> initialize: aValuable at: aTime entryIdentifier: anObject [

	valuable := aValuable.
	scheduledTime := aTime.
	entryIdentifier := anObject.
]

{ #category : #printing }
BlTaskAtQueueTask >> printOn: aStream [

	super printOn: aStream.
	aStream 
		<< '(';
		print: scheduledTime;
		<< ')'
]

{ #category : #accessing }
BlTaskAtQueueTask >> queue [
	^ queue
]

{ #category : #accessing }
BlTaskAtQueueTask >> queue: anObject [
	queue := anObject
]

{ #category : #accessing }
BlTaskAtQueueTask >> scheduledTime [
	<return: #DateAndTime>

	^ scheduledTime
]

{ #category : #accessing }
BlTaskAtQueueTask >> scheduledTime: aDateAndTime [

	scheduledTime := aDateAndTime
]

{ #category : #accessing }
BlTaskAtQueueTask >> valuable [
	^ valuable
]

{ #category : #evaluating }
BlTaskAtQueueTask >> value [
	"evaluate valuable"
	^ self valuable value
]