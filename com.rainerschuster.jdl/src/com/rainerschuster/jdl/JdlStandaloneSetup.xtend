/*
 * generated by Xtext 2.10.0
 */
package com.rainerschuster.jdl


/**
 * Initialization support for running Xtext languages without Equinox extension registry.
 */
class JdlStandaloneSetup extends JdlStandaloneSetupGenerated {

	def static void doSetup() {
		new JdlStandaloneSetup().createInjectorAndDoEMFRegistration()
	}
}
