Class {
	#name : #ProcessMonitorTestServiceNewProcessSignal,
	#superclass : #ContextStackSignal,
	#instVars : [
		'service',
		'process'
	],
	#category : #'Futures-SUnit-Executor - Test Support'
}

{ #category : #accessing }
ProcessMonitorTestServiceNewProcessSignal >> process [
	^ process
]

{ #category : #accessing }
ProcessMonitorTestServiceNewProcessSignal >> process: anObject [
	process := anObject
]

{ #category : #accessing }
ProcessMonitorTestServiceNewProcessSignal >> service [
	^ service
]

{ #category : #accessing }
ProcessMonitorTestServiceNewProcessSignal >> service: anObject [
	service := anObject
]
