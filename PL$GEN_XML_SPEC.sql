create or replace PACKAGE PL$GEN_XML AS
/**
* Project PL/SQL XML
* Author: Van Roy Thomas
* Description
* Create an XML file with the DBMS_XMLDOM package.
*
* The MIT License (MIT)
* 
* Copyright (c) 2015 Van Roy Thomas
* 
* Permission is hereby granted, free of charge, to any person obtaining a copy
* of this software and associated documentation files (the "Software"), to deal
* in the Software without restriction, including without limitation the rights
* to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
* copies of the Software, and to permit persons to whom the Software is
* furnished to do so, subject to the following conditions:
* 
* The above copyright notice and this permission notice shall be included in
* all copies or substantial portions of the Software.
* 
* THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
* IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
* FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
* AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
* LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
* OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
* THE SOFTWARE.
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