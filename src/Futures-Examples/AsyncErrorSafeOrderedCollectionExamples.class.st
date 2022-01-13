Class {
	#name : #AsyncErrorSafeOrderedCollectionExamples,
	#superclass : #Object,
	#category : #'Futures-Examples'
}

{ #category : #examples }
AsyncErrorSafeOrderedCollectionExamples >> doWithError [
	<gtExample>
	| aCollection performedDo |
	
	performedDo := OrderedCollection new.
	
	aCollection := AsyncErrorSafeOrderedCollection withAll: { 1 . 2 . 3. 4. 5 }.
	
	"do: block was evaluated for all items, even ones after the error"
	[ aCollection do: [ :each | 1 / (each - 3). performedDo add: each ] ]
		on: ZeroDivide
		do: [ :e | ].
	
	self assert: performedDo asArray equals: { 1 . 2 . 4 . 5 }.
	
	^ aCollection
]
