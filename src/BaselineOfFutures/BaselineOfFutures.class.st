Class {
	#name : #BaselineOfFutures,
	#superclass : #BaselineOf,
	#category : #BaselineOfFutures
}

{ #category : #baselines }
BaselineOfFutures >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec baseline: 'BeaconCore' with: [
			spec repository: 'github://feenkcom/pharo-beacon/repository' ].
		"spec baseline: 'GToolkitBasicUtility' with: [ 
			spec repository: 'github://feenkcom/gtoolkit-utility:main/src' ]."
		spec package: #'Futures' with: [
			spec requires: #('BeaconCore') ].
		spec package: #'Futures-Extra' with: [
			"It depends on it, but we have a circular dependency between 
			gtoolkit-utility and future repositories, detectable by calling
			`GtRlReleaserExportWorkflow buildGToolkitRelease`."
			spec requires: #('Futures' "'GToolkitBasicUtility'" ) ].
		spec package: #'Futures-Examples' with: [
			spec requires: #('Futures' 'Futures-Extra') ] ]
]
