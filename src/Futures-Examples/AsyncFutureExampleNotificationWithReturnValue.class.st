Class {
	#name : #AsyncFutureExampleNotificationWithReturnValue,
	#superclass : #Notification,
	#instVars : [
		'value'
	],
	#category : #'Futures-Examples'
}

{ #category : #accessing }
AsyncFutureExampleNotificationWithReturnValue >> defaultAction [
	^ value
]

{ #category : #accessing }
AsyncFutureExampleNotificationWithReturnValue >> value: anObject [

	value := anObject
]
