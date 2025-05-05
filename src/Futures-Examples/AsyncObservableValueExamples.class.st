Class {
	#name : #AsyncObservableValueExamples,
	#superclass : #Object,
	#category : #'Futures-Examples-Observable'
}

{ #category : #examples }
AsyncObservableValueExamples >> observableValueNoLeak [
	<gtExample>
	<return: #WeakArray>
	| observable weakObservable finalized block semaphore |
	"observable creates and awaits for a future. Make sure it does not leak"
	observable := AsyncObservableValue new.
	observable value: 42.

	weakObservable := observable asWeakReference.

	finalized := false.
	semaphore := Semaphore new.
	block := [ :v | 
		finalized := v.
		semaphore signal ].

	observable
		toFinalizeSend: #value:
		to: block
		with: true.

	observable := nil.
	Smalltalk garbageCollect.	"finalize it"
	semaphore waitTimeoutSeconds: 30.

	self assert: finalized.

	^ weakObservable
]
