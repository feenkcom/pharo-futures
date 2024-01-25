Class {
	#name : #AsyncSortedDictionary,
	#superclass : #Object,
	#instVars : [
		'dictionary',
		'orderedKeys',
		'sortsByKeys'
	],
	#category : #'Futures-Collections - Dictionary'
}

{ #category : #'instance creation' }
AsyncSortedDictionary class >> new [
	^ self new: 10
]

{ #category : #'instance creation' }
AsyncSortedDictionary class >> new: aCapacity [
	^ self basicNew initialize: aCapacity
]

{ #category : #'instance creation' }
AsyncSortedDictionary class >> sortByAssociations: aSortBlock [
	^ self new sortByAssociations: aSortBlock
]

{ #category : #'instance creation' }
AsyncSortedDictionary class >> sortByKeys: aSortBlock [
	^ self new sortByKeys: aSortBlock
]

{ #category : #'instance creation' }
AsyncSortedDictionary class >> sortByValues: aSortBlock [
	^ self new sortByValues: aSortBlock
]

{ #category : #accessing }
AsyncSortedDictionary >> associationAt: aKey [
	^ dictionary associationAt: aKey
]

{ #category : #accessing }
AsyncSortedDictionary >> associations [
	| associations i |
	associations := Array new: self size.
	i := 1.
	self
		associationsDo: [ :each | 
			associations at: i put: each.
			i := i + 1 ].
	^ associations
]

{ #category : #enumerating }
AsyncSortedDictionary >> associationsDo: aBlock [
	self keysDo: [ :each | aBlock value: (self associationAt: each) ]
]

{ #category : #accessing }
AsyncSortedDictionary >> at: aKey [
	^ dictionary at: aKey
]

{ #category : #accessing }
AsyncSortedDictionary >> at: aKey add: aValue [
	| previousValueKeyIndex |
	
	dictionary
		at: aKey
		update: [ :existingValue |
			"if we sort only by keys, there is no need to update the keys collection"
			previousValueKeyIndex := sortsByKeys
				ifTrue: [ nil ]
				ifFalse: [
					self
						indexOfKey: aKey
						ifAbsent:  [ orderedKeys errorNotFound: aKey ] ].
			existingValue asOrderedCollection
				add: aValue;
				yourself
		] initial: [
			previousValueKeyIndex := 0.
			OrderedCollection with: aValue ].	
	
	previousValueKeyIndex
		ifNil: [ ^ self ].
	
	previousValueKeyIndex > 0
		ifTrue: [
			self
				updateKeyPosition: aKey
				previousIndex: previousValueKeyIndex ]
		ifFalse: [ orderedKeys add: aKey ].
	^ aValue.
]

{ #category : #accessing }
AsyncSortedDictionary >> at: aKey put: aValue [
	| previousValueKeyIndex |
	
	dictionary
		at: aKey
		update: [ :existingValue |
			"if we sort only by keys, there is no need to update the keys collection"
			previousValueKeyIndex := sortsByKeys
				ifTrue: [ nil ]
				ifFalse: [
					self
						indexOfKey: aKey
						ifAbsent:  [ orderedKeys errorNotFound: aKey ]  ].
			aValue
		] initial: [
			previousValueKeyIndex := 0.
			aValue ].	
	
	previousValueKeyIndex
		ifNil: [ ^ self ].
	
	previousValueKeyIndex > 0
		ifTrue: [
			self
				updateKeyPosition: aKey
				previousIndex: previousValueKeyIndex ]
		ifFalse: [ orderedKeys add: aKey ].
	^ aValue.
]

{ #category : #accessing }
AsyncSortedDictionary >> dictionaryClass [
	^ Dictionary
]

{ #category : #enumerating }
AsyncSortedDictionary >> do: aBlock [
	self valuesDo: aBlock
]

{ #category : #private }
AsyncSortedDictionary >> findIndexForInserting: aKey from: aStartIndex to: anEndIndex [
	| index low high |
	low := aStartIndex.
	high := anEndIndex.
	[ index := high + low // 2.  low > high]
		whileFalse: 
			[ (orderedKeys sortBlock  value: (orderedKeys at: index) value: aKey)
				ifTrue: [low := index + 1]
				ifFalse: [high := index - 1]].
	^low
]

{ #category : #accessing }
AsyncSortedDictionary >> gtItemsFor: aView [
	<gtView>
	^ aView columnedTree
		title: 'Items';
		items: [ self associations ];
		children: [ :each | 
			each value isDictionary
				ifTrue: [ each value associations ]
				ifFalse: [ (each value isArray and: [ each value allSatisfy: #isDictionary ])
						ifTrue: [ each value collectWithIndex: [ :x :i | i -> x ] ]
						ifFalse: [ #() ] ] ];
		column: 'Key' text: #key;
		column: 'Value' text: #value weight: 3;
		contextItemLabel: 'Inspect key' action: [ :anElement :assoc | anElement phlow spawnObject: assoc value key ];
		contextItemLabel: 'Inspect association' action: [ :anElement :assoc | anElement phlow spawnObject: assoc value ];
		send: #value
]

{ #category : #accessing }
AsyncSortedDictionary >> indexOfKey: aKey [
	^ self indexOfKey: aKey ifAbsent: [0]
]

{ #category : #accessing }
AsyncSortedDictionary >> indexOfKey: aKey ifAbsent: aBlock [
	^ orderedKeys
		detectIndex: [ :each | each = aKey ]
		ifNone: aBlock
	"^ orderedKeys
		findBinaryIndex:  [ :eachKey |
			eachKey = aKey
				ifTrue: [ 0 ]
				ifFalse: [
					(orderedKeys sortBlock value: eachKey value: aKey)
						ifTrue: [ 1 ]
						ifFalse: [ -1 ] ] ]
		ifNone: [ :a :b |
			(a max: 1) to: orderedKeys size
				do: [ :i |
					(orderedKeys at: i) = aKey
						ifTrue: [ ^ i ] ].
				aBlock value ]"
]

{ #category : #private }
AsyncSortedDictionary >> initialize: aCapacity [
	dictionary := self dictionaryClass new: aCapacity.
	orderedKeys := SortedCollection new: aCapacity.
	sortsByKeys := true.
]

{ #category : #enumerating }
AsyncSortedDictionary >> keysDo: aBlock [
	1 to: self size do: [ :i | aBlock value: (orderedKeys at: i) ]
]

{ #category : #private }
AsyncSortedDictionary >> moveKey: aKey from: aPreviousIndex to: aNewIndex [
	| previousValueKeyIndex newValueKeyIndex anArray |
	
	previousValueKeyIndex := orderedKeys asyncCollectorIndex: aPreviousIndex.
	newValueKeyIndex := orderedKeys asyncCollectorIndex: aNewIndex.
	
	newValueKeyIndex = previousValueKeyIndex
		ifTrue: [ ^ self ].
	
	anArray := orderedKeys collector.
	newValueKeyIndex < previousValueKeyIndex
		ifTrue: [
			| previousValue nextValue|
			previousValue := anArray at: newValueKeyIndex.
			newValueKeyIndex + 1 to: previousValueKeyIndex do: [ :index |
				nextValue := anArray at: index.
				anArray at: index put: previousValue.
				previousValue := nextValue ] ]
		ifFalse: [
			| nextValue|
			nextValue := anArray at: previousValueKeyIndex + 1.
			previousValueKeyIndex + 1 to: newValueKeyIndex do: [ :index |
				anArray at: index - 1 put: nextValue.
				nextValue := anArray at: index + 1 ifAbsent: [ nil ] ] ].
	
	anArray at: newValueKeyIndex put: aKey
]

{ #category : #accessing }
AsyncSortedDictionary >> size [
	^ dictionary size
]

{ #category : #accessing }
AsyncSortedDictionary >> sortByAssociations: aSortBlock [
	sortsByKeys := false.
	orderedKeys sortBlock: [ :a :b | aSortBlock value: (self associationAt: a) value: (self associationAt: b) ]
]

{ #category : #accessing }
AsyncSortedDictionary >> sortByKeys: aSortBlock [
	sortsByKeys := true.
	orderedKeys sortBlock: aSortBlock
]

{ #category : #accessing }
AsyncSortedDictionary >> sortByValues: aSortBlock [
	sortsByKeys := false.
	orderedKeys sortBlock: [ :a :b | aSortBlock value: (self at: a) value: (self at: b) ]
]

{ #category : #private }
AsyncSortedDictionary >> updateKeyPosition: aKey previousIndex: previousValueKeyIndex [
	| shouldMoveForward shouldMoveBackwards newIndex|
	
	sortsByKeys
		ifTrue: [ ^ self ].
		
	self size = 1
		ifTrue: [ ^ self ].
	
	shouldMoveBackwards := previousValueKeyIndex > 1.
	shouldMoveForward := previousValueKeyIndex < self size.
	
	shouldMoveForward
		ifTrue: [
			shouldMoveForward := orderedKeys sortBlock
				value: (orderedKeys at: previousValueKeyIndex + 1)
				value: aKey ].
				
	shouldMoveBackwards
		ifTrue: [
			shouldMoveBackwards := orderedKeys sortBlock
				value: aKey 
				value: (orderedKeys at: previousValueKeyIndex - 1) ].
	
	shouldMoveForward = shouldMoveBackwards
		ifTrue: [ ^ self ].
	
	newIndex := shouldMoveForward
		ifTrue: [
			(previousValueKeyIndex + 1) = self size
				ifTrue:  [ self size ]
				ifFalse: [
					(self
						findIndexForInserting: aKey
						from: previousValueKeyIndex + 1 to: self size) - 1 ] ]
		ifFalse: [
			1 = (previousValueKeyIndex - 1)
				ifTrue: [ 1 ]
				ifFalse: [
					(self
						findIndexForInserting: aKey
						from: 1 to: previousValueKeyIndex - 1) ] ].
	
	self
		moveKey: aKey
		from: previousValueKeyIndex
		to: newIndex
]

{ #category : #enumerating }
AsyncSortedDictionary >> valuesDo: aBlock [
	self keysDo: [:each | aBlock value: (self at: each) ]
]
