create or replace PACKAGE BODY PL$GEN_XML AS
/*
The MIT License (MIT)

Copyright (c) 2015 Van Roy Thomas

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
*/
--------------------------------------------------------------------------------
-- LOCAL PRIVATE VARIABLES
-- @G_XML_DOCUMENT    :  The XML document wich should be initializede by PROC initalizeDOMDocument
-- @G_XML_ROOT_NODE   :  The root node wich will be used if the parent node is empty
-- @G_XML_ROOTELEMENT :
-- @G_XML_Attribute   :
--------------------------------------------------------------------------------  
  G_XML_DOCUMENT     DBMS_XMLDOM.DOMDocument;
  G_XML_ROOT_NODE    DBMS_XMLDOM.DOMNode;
  G_XML_ROOTELEMENT  DBMS_XMLDOM.DOMElement;
  G_XML_Attribute    DBMS_XMLDOM.DOMAttr;

--------------------------------------------------------------------------------
-- LOCAL PRIVATE PROCEDURE set_xml_document
--------------------------------------------------------------------------------
  PROCEDURE set_xml_document(p_xml_document  IN DBMS_XMLDOM.DOMDocument) AS
    -- declare
  BEGIN
    -- SET
    G_XML_DOCUMENT := p_xml_document;
  END set_xml_document;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL PRIVATE PROCEDURE set_xml_root_node
--------------------------------------------------------------------------------  
  PROCEDURE set_xml_root_node(p_xml_root_node IN DBMS_XMLDOM.DOMNode) AS
    -- declare
  BEGIN
    -- SET
    G_XML_ROOT_NODE := p_xml_root_node;
  END set_xml_root_node;
--------------------------------------------------------------------------------

---------------get_xml_document-----------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION get_xml_document
--------------------------------------------------------------------------------
  FUNCTION get_xml_document
    RETURN DBMS_XMLDOM.DOMDocument AS
    -- declare
    l_return DBMS_XMLDOM.DOMDocument;
  BEGIN
    -- SET
    l_return := G_XML_DOCUMENT;
    RETURN l_return;
  END;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION get_xml_root_node
--------------------------------------------------------------------------------  
  FUNCTION get_xml_root_node
    RETURN DBMS_XMLDOM.DOMNode AS
    -- declare
    l_return DBMS_XMLDOM.DOMNode;
  BEGIN
    -- SET
    l_return := G_XML_ROOT_NODE;
    RETURN l_return;
  END;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION findDOMNode
--------------------------------------------------------------------------------  
  FUNCTION findDOMNode(p_node_name   IN VARCHAR2
                      ,p_parent_node IN DBMS_XMLDOM.DOMNode)
    RETURN DBMS_XMLDOM.DOMNode AS
    -- declare
    l_return     DBMS_XMLDOM.DOMNode;
    l_node_list  DBMS_XMLDOM.DOMNodeList;
    l_node_name  VARCHAR2(100);
  BEGIN
    
    l_node_list := DBMS_XMLDOM.GETCHILDNODES(p_parent_node);
    FOR i IN 0..DBMS_XMLDOM.GETLENGTH(l_node_list)-1 LOOP
      -- get node
      l_return    := DBMS_XMLDOM.item(l_node_list, i);
      -- get node name
      l_node_name := DBMS_XMLDOM.getNodeName(l_return);
      IF G_DEBUG_ENABLED THEN
        DBMS_OUTPUT.PUT_LINE('findDOMNode Nodename: ' || l_node_name);
      END IF;
      -- check if it is the node you are looking for
      IF l_node_name = p_node_name  THEN
        -- exit when the node is found
        EXIT;
      END IF;
    END LOOP;
    
    RETURN l_return;
  END findDOMNode;
--------------------------------------------------------------------------------

--------------------------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION addDOMNodeAttributes
--------------------------------------------------------------------------------  
  PROCEDURE addDOMNodeAttributes(p_node_attributes IN PL$GEN_XML.attributes_table_tp
                               , p_xml_element     IN DBMS_XMLDOM.DOMElement) AS
   -- declare
   l_key    VARCHAR2(100);
   l_value  VARCHAR2(100);
  BEGIN
  
    l_key := p_node_attributes.FIRST;
    WHILE l_key IS NOT NULL LOOP
    
      l_value := p_node_attributes(l_key);
      DBMS_XMLDOM.setAttribute(
          p_xml_element
        , l_key
        , l_value
      );
      
      l_key := p_node_attributes.NEXT(l_key);
    END LOOP;
    
  END addDOMNodeAttributes;
--------------------------------------------------------------------------------       

--------------------------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION addDOMElement
--------------------------------------------------------------------------------  
  FUNCTION addDOMElement(p_xml_element     IN DBMS_XMLDOM.DOMElement
                       , p_parent_node     IN VARCHAR2
                       , p_node_attributes IN PL$GEN_XML.attributes_table_tp)
    RETURN DBMS_XMLDOM.DOMNode AS
   -- declare
   l_root_node   DBMS_XMLDOM.DOMNode := get_xml_root_node();
   l_return      DBMS_XMLDOM.DOMNode;
   
  BEGIN
    
    addDOMNodeAttributes(p_node_attributes => p_node_attributes
                       , p_xml_element     => p_xml_element);
    
    IF p_parent_node IS NOT NULL THEN
      IF G_DEBUG_ENABLED THEN
        DBMS_OUTPUT.PUT_LINE('addDOMElement Root node: '|| DBMS_XMLDOM.GETNODENAME(l_root_node));
      END IF;
      -- find node on root of document
      l_root_node := findDOMNode(p_node_name   => p_parent_node
                               , p_parent_node => l_root_node);

    END IF;

    -- append element on the correct root node
    l_return := DBMS_XMLDOM.appendChild(
                        l_root_node
                      , DBMS_XMLDOM.makeNode(p_xml_element)
                    );
    -- return the node
    RETURN l_return;
    
  END addDOMElement;
--------------------------------------------------------------------------------


--------------------------------------------------------------------------------
-- LOCAL PRIVATE FUNCTION addDOMNodeText
--------------------------------------------------------------------------------  
  FUNCTION addDOMNodeText(p_node_text IN VARCHAR2
                        , p_node      IN DBMS_XMLDOM.DOMNode)
    RETURN DBMS_XMLDOM.DOMNode AS
   -- declare
   l_node_text DBMS_XMLDOM.DOMText;
   l_return    DBMS_XMLDOM.DOMNode; 
   
  BEGIN
    
    l_node_text := DBMS_XMLDOM.createTextNode(
                       get_xml_document()
                     , p_node_text
                   );
    
    l_return    := DBMS_XMLDOM.appendChild(
                       p_node
                     , DBMS_XMLDOM.makeNode(l_node_text)
                   );
                   
    RETURN l_return;
  END addDOMNodeText;
--------------------------------------------------------------------------------               

--------------------------------------------------------------------------------
-- PROCEDURE initializeDOMDocument
--------------------------------------------------------------------------------
  PROCEDURE initializeDOMDocument(p_root_node IN VARCHAR2) AS
    -- declare
    l_xml_doc       DBMS_XMLDOM.DOMDocument;
    l_root_node     DBMS_XMLDOM.DOMNode;
    l_root_element  DBMS_XMLDOM.DOMElement;
  BEGIN
    -- init document
    l_xml_doc      := DBMS_XMLDOM.newDOMDocument();
    -- Create root element with node name
    l_root_element := DBMS_XMLDOM.createElement(
                          l_xml_doc
                        , p_root_node
                      );
    -- Create the root node with the element
    l_root_node    := DBMS_XMLDOM.appendChild(
                          DBMS_XMLDOM.makeNode(l_xml_doc)
                        , DBMS_XMLDOM.makeNode(l_root_element)
                      );
    -- SET private package variables
    set_xml_document(p_xml_document => l_xml_doc);
    set_xml_root_node(p_xml_root_node   => l_root_node);
    
  END initializeDOMDocument;
--------------------------------------------------------------------------------
-- PROCEDURE addNode
--------------------------------------------------------------------------------
  PROCEDURE addNode(p_node_name            IN VARCHAR2
                  , p_parent_node          IN VARCHAR2 DEFAULT NULL
                  , p_node_text            IN VARCHAR2 DEFAULT NULL
                  , p_node_attributes      IN attributes_table_tp DEFAULT CAST(NULL as attributes_table_tp)) AS
    -- declare
    l_xml_doc     DBMS_XMLDOM.DOMDocument;
    l_xml_element DBMS_XMLDOM.DOMElement;
    l_xml_text    DBMS_XMLDOM.DOMText;
    l_xml_node    DBMS_XMLDOM.DOMNode;
     
  BEGIN
    l_xml_doc := get_xml_document();
    l_xml_element := DBMS_XMLDOM.createElement(
                          l_xml_doc
                        , p_node_name
                     );
    l_xml_node := addDOMElement(p_xml_element     => l_xml_element
                              , p_parent_node     => p_parent_node
                              , p_node_attributes => p_node_attributes);
                 
    -- Add text to element
    l_xml_node := addDOMNodeText(p_node_text => p_node_text
                               , p_node      => l_xml_node);
    -- Add attributes to element
        
  END addNode;
--------------------------------------------------------------------------------
-- PROCEDURE addNode
--------------------------------------------------------------------------------
   FUNCTION getDOMDocument
     RETURN DBMS_XMLDOM.DOMDocument AS
    -- declare
    l_return DBMS_XMLDOM.DOMDocument;
  BEGIN
    l_return := get_xml_document();
    RETURN l_return; 
  END getDOMDocument;
--------------------------------------------------------------------------------
-- FUNCTION writeToClob
--------------------------------------------------------------------------------
  FUNCTION writeToClob
    RETURN CLOB AS
    -- declare
    l_return CLOB;
  BEGIN
    -- init
    DBMS_LOB.createTemporary(l_return,TRUE);
    -- write to clob
    DBMS_XMLDOM.writeToClob(get_xml_document(),l_return);
   
    RETURN l_return;
  END writeToClob;
--------------------------------------------------------------------------------    
END PL$GEN_XML;