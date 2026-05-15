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
			baseline: 'BeaconCore' with: [
				spec repository: 'github://feenkcom/pharo-beacon:d1af72fc3fb759440b1b4b3e62144d1c7f8d73f2/repository' ].

		spec package: 'Futures' with: [
			spec requires: #(#BeaconCore) ].
		spec package: 'Futures-Extra' with: [
			spec requires: #(#Futures) ].
		spec package: 'Futures-Examples' with: [
			spec requires: #(#Futures #'Futures-Extra') ].
	]
]
