/*
 * generated by Xtext 2.10.0
 */
package com.rainerschuster.jdl.validation

import org.eclipse.xtext.validation.Check
import com.rainerschuster.jdl.jdlDsl.Option
import com.rainerschuster.jdl.jdlDsl.JdlDslPackage
import com.rainerschuster.jdl.jdlDsl.Field

/**
 * This class contains custom validation rules. 
 *
 * See https://www.eclipse.org/Xtext/documentation/303_runtime_concepts.html#validation
 */
class JdlDslValidator extends AbstractJdlDslValidator {
	
//	public static val INVALID_NAME = 'invalidName'
//
//	@Check
//	def checkGreetingStartsWithCapital(Greeting greeting) {
//		if (!Character.isUpperCase(greeting.name.charAt(0))) {
//			warning('Name should start with a capital', 
//					JdlDslPackage.Literals.GREETING__NAME,
//					INVALID_NAME)
//		}
//	}
	
	public static val INVALID_OPTION = 'invalidOption'
	public static val INVALID_OPTION_VALUE = 'invalidOptionValue'
	public static val INVALID_VALIDATION = 'invalidValidation'

	public static val OPTIONS = #{
		'dto' -> #['mapstruct'],
		'paginate' -> #['pager', 'pagination', 'infinite-scroll'],
		'service' -> #['serviceClass', 'serviceImpl'],
		'skipClient' -> #[],
		'skipServer' -> #[],
		'angularSuffix' -> #[],
		'microservice' -> #[],
		'search' -> #['elasticsearch']
	};

	public static val VALIDATIONS = #{
		'String' -> #['required', 'minlength', 'maxlength', 'pattern'],
		'Integer' -> #['required', 'min', 'max'],
		'Long' -> #['required', 'min', 'max'],
		'BigDecimal' -> #['required', 'min', 'max'],
		'Float' -> #['required', 'min', 'max'],
		'Double' -> #['required', 'min', 'max'],
		'Enum' -> #['required'],
		'Boolean' -> #['required'],
		'LocalDate' -> #['required'],
		'ZonedDateTime' -> #['required'],
		'Blob' -> #['required', 'minbytes', 'maxbytes'],
		'AnyBlob' -> #['required', 'minbytes', 'maxbytes'],
		'ImageBlob' -> #['required', 'minbytes', 'maxbytes'],
		'Date' -> #['required'],
		'UUID' -> #['required']		
	};

	@Check
	def checkOptionValues(Option option) {
		if (OPTIONS.containsKey(option.option)) {
			val supportedOptionValues = OPTIONS.get(option.option);
			if (!supportedOptionValues.contains(option.optionValue)) {
				val message = if (supportedOptionValues.isEmpty) {
					"Unsupported option value! '" + option.option + "' does not support values!"
				} else {
					"Unsupported option value! Supported values for '" + option.option + "' are '" + supportedOptionValues.join(', ') + "'."
				}
				warning(message, 
						JdlDslPackage.Literals.OPTION__OPTION_VALUE,
						INVALID_OPTION_VALUE)
			}
		} else {
			warning("Unknown option! Known options are '" + OPTIONS.keySet.join(', ') + "'.", 
					JdlDslPackage.Literals.OPTION__OPTION,
					INVALID_OPTION)
		}
	}

	@Check
	def checkValidations(Field field) {
		if (VALIDATIONS.containsKey(field.type.value)) {
			val supportedValidations = VALIDATIONS.get(field.type.value);
			field.validation
				.filter[!supportedValidations.contains(it.name)]
				.forEach[
					warning("Unsupported validation! Supported validations for '" + field.type.value + "' are '" + supportedValidations.join(', ') + "'.", 
							JdlDslPackage.Literals.FIELD__VALIDATION,
							INVALID_VALIDATION)
				]
		} else {
			// TODO check reference validations
		}
	}

}
