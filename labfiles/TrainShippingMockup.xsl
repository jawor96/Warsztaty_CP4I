<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"> 
<xsl:output method="xml" indent="yes"/> 
 <xsl:template match="/"> 
  <xsl:element name="Logistics">
   <xsl:element name="userName"> 
    <xsl:value-of select="Customer/userName"/> 
   </xsl:element>
   <xsl:element name="prodID"> 
    <xsl:value-of select="Customer/prodID"/> 
   </xsl:element>
   <xsl:element name="quantity"> 
    <xsl:value-of select="Customer/quantity"/> 
   </xsl:element>
   <xsl:element name="shippingMethod"> 
    <xsl:value-of select="Customer/shippingMethod"/> 
   </xsl:element>
   <xsl:element name="shippingStatus">Train Shipping Successful</xsl:element>
    </xsl:element> 
 </xsl:template> 
</xsl:stylesheet>