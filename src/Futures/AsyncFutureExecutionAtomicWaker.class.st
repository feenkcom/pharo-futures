Class {
	#name : #AsyncFutureExecutionAtomicWaker,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'waker',
		'state'
	],
	#category : #'Futures-Executor'
}

{ #category : #testing }
AsyncFutureExecutionAtomicWaker >> hasWaker [
	^ monitor critical: [ waker notNil ]
]

{ #category : #initialization }
AsyncFutureExecutionAtomicWaker >> initialize [
	super initialize.
	
	monitor := Mutex new.
	state := AsyncFutureExecutionWakerInitialState new
]

{ #category : #'api - execution' }
AsyncFutureExecutionAtomicWaker >> register: aWaker [
	monitor critical: [
		waker := aWaker.
		state := self state registeredState ]
]

{ #category : #accessing }
AsyncFutureExecutionAtomicWaker >> state [
	^ state ifNil: [ AsyncFutureExecutionWakerInitialState new ]
]

{ #category : #'api - execution' }
AsyncFutureExecutionAtomicWaker >> unregister [
	monitor critical: [
		waker := nil.
		state := self state unregisteredState ]
]

{ #category : #'api - execution' }
AsyncFutureExecutionAtomicWaker >> wakeUp [
	monitor critical: [
		state := self state wokenUpState.
		waker
			ifNotNil: [ :aWaker |
				waker := nil.
				aWaker wakeUp ] ]
]

{ #category : #accessing }
AsyncFutureExecutionAtomicWaker >> waker [
	^ waker
]
