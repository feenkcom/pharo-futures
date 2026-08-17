Class {
	#name : #BaselineOfFuturesCore,
	#superclass : #BaselineOf,
	#category : #BaselineOfFuturesCore
}

{ #category : #baselines }
BaselineOfFuturesCore >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec baseline: 'BeaconCore' with: [
			spec repository: 'github://feenkcom/pharo-beacon:main/src' ].
		spec package: #'Futures' with: [
			spec requires: #('BeaconCore') ]. ]
]
