Class {
	#name : #AsyncFutureExampleUnhandledException,
	#superclass : #UnhandledException,
	#instVars : [
		'errorActionCalled',
		'semaphore',
		'isFrozen'
	],
	#category : #'Futures-Examples'
}

{ #category : #accessing }
AsyncFutureExampleUnhandledException >> errorActionCalled [

	^ errorActionCalled
]

{ #category : #handling }
AsyncFutureExampleUnhandledException >> freeze [
	super freeze.
	
	isFrozen := true
]

{ #category : #initialization }
AsyncFutureExampleUnhandledException >> initialize [
	super initialize.
	
	errorActionCalled := 0.
	isFrozen := false
]

{ #category : #accessing }
AsyncFutureExampleUnhandledException >> isFrozen [

	^ isFrozen
]

{ #category : #accessing }
AsyncFutureExampleUnhandledException >> semaphore: anObject [

	semaphore := anObject
]

{ #category : #handling }
AsyncFutureExampleUnhandledException >> unhandledErrorAction [
	"Normal unhandled exceptions open a debugger here"
	
	errorActionCalled := errorActionCalled + 1.
	semaphore signal.

	"simulates a debugger which terminates the process"
	Processor activeProcess terminate.

	^ nil
]
