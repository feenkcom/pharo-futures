Class {
	#name : #BaselineOfFutures,
	#superclass : #BaselineOf,
	#category : #BaselineOfFutures
}

{ #category : #baseline }
BaselineOfFutures >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'FuturesCore' with: [
				spec repository: 'github://feenkcom/pharo-futures:v0.6.162/src' ].

		spec package: 'Futures-Extra' with: [
			spec requires: #(#FuturesCore) ].
		spec package: 'Futures-Examples' with: [
			spec requires: #(#FuturesCore #'Futures-Extra') ].
	]
]
