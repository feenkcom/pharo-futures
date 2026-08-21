Class {
	#name : #BaselineOfFuturesCore,
	#superclass : #BaselineOf,
	#category : #BaselineOfFuturesCore
}

{ #category : #baseline }
BaselineOfFuturesCore >> baseline: spec [
	<baseline>
	spec for: #'common' do: [
		spec
			baseline: 'BeaconCore' with: [
				spec repository: 'github://feenkcom/pharo-beacon:v0.5.124/src' ].

		spec package: 'Futures' with: [
			spec requires: #(#BeaconCore) ].
	]
]
