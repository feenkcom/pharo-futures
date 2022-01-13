Class {
	#name : #AsyncFutureExampleUnhandledException,
	#superclass : #UnhandledException,
	#instVars : [
		'isFrozen'
	],
	#category : #'Futures-Examples'
}

{ #category : #handling }
AsyncFutureExampleUnhandledException >> freeze [
	super freeze.
	
	isFrozen := true
]

{ #category : #initialization }
AsyncFutureExampleUnhandledException >> initialize [
	super initialize.
	
	isFrozen := false
]

{ #category : #accessing }
AsyncFutureExampleUnhandledException >> isFrozen [

	^ isFrozen
]

{ #category : #handling }
AsyncFutureExampleUnhandledException >> unhandledErrorAction [
	"Normal unhandled exceptions open a debugger here"
	
	"simulates a debugger which terminates the process"
	Processor activeProcess terminate.

	^ nil
]
