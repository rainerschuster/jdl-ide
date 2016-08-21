/*
 * generated by Xtext 2.10.0
 */
package com.rainerschuster.jdl.web

import com.google.inject.Guice
import com.google.inject.Injector
import com.google.inject.Provider
import com.google.inject.util.Modules
import com.rainerschuster.jdl.JdlRuntimeModule
import com.rainerschuster.jdl.JdlStandaloneSetup
import java.util.concurrent.ExecutorService
import org.eclipse.xtend.lib.annotations.FinalFieldsConstructor

/**
 * Initialization support for running Xtext languages in web applications.
 */
@FinalFieldsConstructor
class JdlWebSetup extends JdlStandaloneSetup {
	
	val Provider<ExecutorService> executorServiceProvider;
	
	override Injector createInjector() {
		val runtimeModule = new JdlRuntimeModule()
		val webModule = new JdlWebModule(executorServiceProvider)
		return Guice.createInjector(Modules.override(runtimeModule).with(webModule))
	}
	
}