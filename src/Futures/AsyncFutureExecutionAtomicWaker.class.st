Class {
	#name : #AsyncFutureExecutionAtomicWaker,
	#superclass : #Object,
	#instVars : [
		'monitor',
		'waker'
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
	
	monitor := Monitor new
]

{ #category : #'api - execution' }
AsyncFutureExecutionAtomicWaker >> register: aWaker [
	monitor critical: [ waker := aWaker ]
]

{ #category : #'api - execution' }
AsyncFutureExecutionAtomicWaker >> wakeUp [
	monitor critical: [
		waker ifNotNil: [ :aWaker |
			waker := nil.
			aWaker wakeUp ] ]
]

{ #category : #accessing }
AsyncFutureExecutionAtomicWaker >> waker [
	^ waker
]
