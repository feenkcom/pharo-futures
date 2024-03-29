"
BlTaskAtErrorSignal is used when BlTaskAtQueue encounters an error during execution.

- If the error occurs while evaluating a task the task is set.
- In all cases a message and the exception is set.
 
## Internal Representation and Key Implementation Points.

### Instance Variables

	exception:		<Error>	the exception encountered during execution
	message:			<String>	a message about where the error was encountered
	task:				<Object>	the task being evaluated when the error was encountered


"
Class {
	#name : #TaskAtErrorSignal,
	#superclass : #BeaconSignal,
	#instVars : [
		'exception',
		'message',
		'task'
	],
	#category : #'Futures-Collections - Queue'
}

{ #category : #accessing }
TaskAtErrorSignal >> exception [
	^ exception
]

{ #category : #accessing }
TaskAtErrorSignal >> exception: anObject [
	exception := anObject
]

{ #category : #accessing }
TaskAtErrorSignal >> message [
	^ message
]

{ #category : #accessing }
TaskAtErrorSignal >> message: anObject [
	message := anObject
]

{ #category : #accessing }
TaskAtErrorSignal >> task [
	^ task
]

{ #category : #accessing }
TaskAtErrorSignal >> task: anObject [
	task := anObject
]
