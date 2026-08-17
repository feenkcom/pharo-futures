Class {
	#name : #BaselineOfFutures,
	#superclass : #BaselineOf,
	#category : #BaselineOfFutures
}

{ #category : #baselines }
BaselineOfFutures >> baseline: spec [
	<baseline>

	spec for: #'common' do: [
		spec baseline: 'FuturesCore' with: [
			spec repository: 'github://feenkcom/pharo-futures:main/src' ].
		"spec baseline: 'GToolkitBasicUtility' with: [ 
			spec repository: 'github://feenkcom/gtoolkit-utility:main/src' ]."
		spec package: #'Futures-Extra' with: [
			"It depends on it, but we have a circular dependency between 
			gtoolkit-utility and future repositories, detectable by calling
			`GtRlReleaserExportWorkflow buildGToolkitRelease`."
			spec requires: #('FuturesCore' "'GToolkitBasicUtility'" ) ].
		spec package: #'Futures-Examples' with: [
			spec requires: #('FuturesCore' 'Futures-Extra') ] ]
]
