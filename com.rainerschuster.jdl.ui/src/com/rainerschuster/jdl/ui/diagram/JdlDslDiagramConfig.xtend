package com.rainerschuster.jdl.ui.diagram

import de.fxdiagram.eclipse.xtext.mapping.AbstractXtextDiagramConfig
import de.fxdiagram.mapping.ConnectionLabelMapping
import de.fxdiagram.mapping.ConnectionMapping
import de.fxdiagram.mapping.DiagramMapping
import de.fxdiagram.mapping.MappingAcceptor
import de.fxdiagram.mapping.NodeHeadingMapping
import de.fxdiagram.mapping.NodeMapping

import static de.fxdiagram.mapping.shapes.BaseNode.*

import static extension de.fxdiagram.core.extensions.ButtonExtensions.*
import static extension org.eclipse.xtext.EcoreUtil2.*
import com.rainerschuster.jdl.jdlDsl.Model
import com.rainerschuster.jdl.jdlDsl.Entity
import com.rainerschuster.jdl.jdlDsl.Relationship
import de.fxdiagram.mapping.IMappedElementDescriptor
import de.fxdiagram.mapping.NodeLabelMapping
import com.rainerschuster.jdl.jdlDsl.Field
import de.fxdiagram.mapping.shapes.BaseConnection
import de.fxdiagram.core.anchors.LineArrowHead
import de.fxdiagram.mapping.shapes.BaseClassNode

import static de.fxdiagram.mapping.shapes.BaseClassNode.*
import de.fxdiagram.core.XConnectionLabel
import com.rainerschuster.jdl.jdlDsl.Enumeration
import com.rainerschuster.jdl.jdlDsl.RelationshipItem

// TODO de.fxdiagram.xtext.xbase.JvmClassDiagramConfig
class JdlDslDiagramConfig extends AbstractXtextDiagramConfig {

	val jdlDiagram = new DiagramMapping<Model>(this, 'jdlDiagram', 'JDL') {
		override calls() {
			// when adding a jdl diagram automatically add a node for each state
			// and a connection for each relationship
			entityNode.nodeForEach[elements.filter(Entity)]
			enumerationNode.nodeForEach[elements.filter(Enumeration)]
			relationshipItemConnection.connectionForEach[elements.filter(Relationship).map[items].flatten]
			eagerly(propertyConnection, propertyEnumerationConnection)
		}

		override getDefaultFilePath(Model element) {
			element.filePath
		}
	}

	val enumerationNode = new NodeMapping<Enumeration>(this, 'enumerationNode', 'Enumeration') {
		override createNode(IMappedElementDescriptor<Enumeration> descriptor) {
			new BaseClassNode(descriptor)
		}

		override protected calls() {
			enumerationName.labelFor[it]
//			enumerationItem.labelForEach[items]
		}
	}

	val enumerationName = new NodeHeadingMapping<Enumeration>(this, CLASS_NAME) {
		override getText(Enumeration it) {
			'<< Enumeration >> ' + name
		}
	}

	val enumerationItem = new NodeLabelMapping<String>(this, ATTRIBUTE) {
		override getText(String it) {
			it
		}
	}

	val entityNode = new NodeMapping<Entity>(this, 'entityNode', 'Entity') {
		override createNode(IMappedElementDescriptor<Entity> descriptor) {
			new BaseClassNode(descriptor)
		}

		override protected calls() {
			entityName.labelFor[it]
			attribute.labelForEach[fields.filter[type.ref/*erencedEntity*/ == null]]
//			propertyConnection.outConnectionForEach [
//				fields.filter[type.ref/*erencedEntity*/ != null]
//			].asButton[getArrowButton("Add property")]
			propertyConnection.outConnectionForEach [
				fields.filter[type.ref/*erencedEntity*/ != null && type.ref instanceof Entity]
			].asButton[getArrowButton("Add property")]
			propertyEnumerationConnection.outConnectionForEach [
				fields.filter[type.ref/*erencedEntity*/ != null && type.ref instanceof Enumeration]
			].asButton[getArrowButton("Add property")]
			// when adding a state allow to explore its relationships via rapid button
//			relationshipConnection.outConnectionForEach[relationships].asButton[
//				getArrowButton('Add Relationship')
//			]
		}
	}

	val entityName = new NodeHeadingMapping<Entity>(this, CLASS_NAME) {
		override getText(Entity it) {
			name
		}
	}

	val attribute = new NodeLabelMapping<Field>(this, ATTRIBUTE) {
		override getText(Field it) {
			'''«name»: «type.value»'''
		} // TODO type.simpleName
	}

	val propertyConnection = new ConnectionMapping<Field>(this, 'propertyConnection', 'Property') {
		override createConnection(IMappedElementDescriptor<Field> descriptor) {
			new BaseConnection(descriptor) => [
				targetArrowHead = new LineArrowHead(it, false)
			]
		}

		override calls() {
			propertyName.labelFor[it];
			entityNode.target[type.ref as Entity]
//			enumerationNode.target[if (type.ref instanceof Enumeration) type.ref as Enumeration]
		}
	}

	val propertyName = new ConnectionLabelMapping<Field>(this, 'propertyName') {
		override getText(Field it) {
			name
		}
	}

	val propertyEnumerationConnection = new ConnectionMapping<Field>(this, 'propertyEnumerationConnection', 'PropertyEnumeration') {
		override createConnection(IMappedElementDescriptor<Field> descriptor) {
			new BaseConnection(descriptor) => [
				targetArrowHead = new LineArrowHead(it, false)
			]
		}

		override calls() {
			propertyEnumerationName.labelFor[it];
			enumerationNode.target[if (type.ref instanceof Enumeration) type.ref as Enumeration]
		}
	}

	val propertyEnumerationName = new ConnectionLabelMapping<Field>(this, 'propertyEnumerationName') {
		override getText(Field it) {
			name
		}
	}

//	val relationshipConnection = new ConnectionMapping<Relationship>(this, 'relationshipConnection', 'Relationship') {
//		override protected calls() {
//			relationshipItemConnection.connectionForEach[items]
//		}
//	}

	val relationshipItemConnection = new ConnectionMapping<RelationshipItem>(this, 'relationshipItemConnection', 'Relationship') {
		override protected calls() {
//			multiplicityLabel.labelFor[it]
			fromLabel.labelFor[it]
			toLabel.labelFor[it]
			// when adding a relationship, automatically add its source and target
			entityNode.source[from]
			entityNode.target[if (to instanceof Entity) to as Entity]
		}
	}

//	val multiplicityLabel = new ConnectionLabelMapping<Relationship>(this, 'multiplicityLabel') {
//		override getText(Relationship it) {
//			multiplicity.literal // multiplicity.TODO name?
//		}
//	}

	val fromLabel = new ConnectionLabelMapping<RelationshipItem>(this, 'fromLabel') {
		override getText(RelationshipItem it) {
			var text = fromFieldName;
			if (text == null) {
				text = from?.name
			}
			if (text == null) {
				text = ""
			}
			text += " ";
			text += " [";
//			text += switch(multiplicity) {
//				case ONE_TO_MANY: '1'
//				case MANY_TO_ONE: '*'
//				case ONE_TO_ONE: '1'
//				case MANY_TO_MANY: '*'
//			}
			text += "]";
			text
		}
		override XConnectionLabel createLabel(IMappedElementDescriptor<RelationshipItem> descriptor, RelationshipItem labelElement) {
			val label = super.createLabel(descriptor, labelElement);
			label.position = 0.2;
			label
		}
	}

	val toLabel = new ConnectionLabelMapping<RelationshipItem>(this, 'toLabel') {
		override getText(RelationshipItem it) {
			var text = toFieldName;
			if (text == null) {
				text = to?.name
			}
			if (text == null) {
				text = ""
			}
			text += " ";
			text += " [";
//			text += switch(multiplicity) {
//				case ONE_TO_MANY: '*'
//				case MANY_TO_ONE: '1'
//				case ONE_TO_ONE: '1'
//				case MANY_TO_MANY: '*'
//			}
			text += "]";
			text
		}
		override XConnectionLabel createLabel(IMappedElementDescriptor<RelationshipItem> descriptor, RelationshipItem labelElement) {
			val label = super.createLabel(descriptor, labelElement);
			label.position = 0.8;
			label
		}
	}

	override protected <ARG> entryCalls(ARG domainArgument, extension MappingAcceptor<ARG> acceptor) {
		switch domainArgument {
			Model: 
				add(jdlDiagram)
			Entity: {
				add(jdlDiagram, [domainArgument.getContainerOfType(Model)])
				add(entityNode, [domainArgument])
			}
			Enumeration: {
				add(jdlDiagram, [domainArgument.getContainerOfType(Model)])
				add(enumerationNode, [domainArgument])
			}
			RelationshipItem: {
				add(jdlDiagram, [domainArgument.getContainerOfType(Model)])	
				add(relationshipItemConnection, [domainArgument])
			}
//			Relationship: {
//				add(jdlDiagram, [domainArgument.getContainerOfType(Model)])	
//				add(relationshipConnection, [domainArgument])
//			}
			Field: {
				add(propertyConnection)
				add(propertyEnumerationConnection)
			}
		}
	}
}