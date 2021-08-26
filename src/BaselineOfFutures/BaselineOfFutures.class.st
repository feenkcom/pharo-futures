Class {
	#name : 'BaselineOfFutures',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfFutures'
}

{ #category : 'baselines' }
BaselineOfFutures >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec package: #'Futures'.
		spec package: #'Futures-Extra' with: [
				spec requires: #('Futures' ) ] ]
]
