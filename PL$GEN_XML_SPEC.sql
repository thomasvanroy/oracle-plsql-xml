create or replace PACKAGE PL$GEN_XML AS
/**
* Project XMLDOM generate XML document
* Author: Van Roy Thomas
* Description
* Create an XML file with the DBMS_XMLDOM file.
*
*/
 
 /**
 * TYPE attributes_table_tp
 * Used for adding attributes in the addNode function
 * @index VARCHAR2: name  of the attribute
 * @value VARCHAR2: value of the attribute
 */
 TYPE attributes_table_tp IS TABLE OF VARCHAR2(50) INDEX BY VARCHAR2(50);
 /**
 * Debug on or off
 */
 G_DEBUG_ENABLED BOOLEAN := FALSE;
 
 /**
 * PROCEDURE initializeDOMDocument
 *   Procedure that will create a XML Document with a root node 
 *
 * @param p_root_node: The name of the root node that will add  
 */
 PROCEDURE initializeDOMDocument(p_root_node IN VARCHAR2);
 
 /**
 * PROCEDURE addNode
 *   Procedure that will add a node 
 *
 * @param p_node_name  : The name of the node that shoud be added 
 * @param p_parent_node: The name of the parent node if empty it will be added to the root
 * @param p_node_text  : The text added to the node element
 *
 */
 PROCEDURE addNode(p_node_name            IN VARCHAR2
                 , p_parent_node          IN VARCHAR2 DEFAULT NULL
                 , p_node_text            IN VARCHAR2 DEFAULT NULL
                 , p_node_attributes      IN attributes_table_tp DEFAULT CAST(NULL as attributes_table_tp));
 
 /**
 * FUNCTION getDOMDocument
 *   Get the created DOMDocument
 * @return DOMDocument:  The XML document
 */
 FUNCTION getDOMDocument
   RETURN DBMS_XMLDOM.DOMDocument;
 
 /**
 * FUNCTION writeToClob
 *   Get the created DOMDocument in clob
 * @return CLOB:  The XML document in a clob variable
 */
 FUNCTION writeToClob
  RETURN CLOB;

END PL$GEN_XML;