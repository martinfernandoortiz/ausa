<?xml version="1.0" encoding="UTF-8"?>
<StyledLayerDescriptor xmlns="http://www.opengis.net/sld" xmlns:se="http://www.opengis.net/se" xsi:schemaLocation="http://www.opengis.net/sld http://schemas.opengis.net/sld/1.1.0/StyledLayerDescriptor.xsd" xmlns:ogc="http://www.opengis.net/ogc" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" version="1.1.0" xmlns:xlink="http://www.w3.org/1999/xlink">
  <NamedLayer>
    <se:Name>Inspeccion Defensa</se:Name>
    <UserStyle>
      <se:Name>Pendiente</se:Name>
      <se:FeatureTypeStyle>
        <se:Rule>
          <se:Name>Inspección Defensa</se:Name>
          <ogc:Filter>
            <ogc:PropertyIsNull>
              <ogc:PropertyName>linkeditorrelativo</ogc:PropertyName>
            </ogc:PropertyIsNull>
          </ogc:Filter>
          <!-- Control de escala: visible entre 1:1000 y 1:10000 -->
          <se:MinScaleDenominator>1</se:MinScaleDenominator>
          <se:MaxScaleDenominator>150000</se:MaxScaleDenominator>
          <se:PointSymbolizer>
            <se:Graphic>

              <se:ExternalGraphic>
                <se:OnlineResource xlink:type="simple" xlink:href="inspection_d.svg"/>
                <se:Format>image/svg+xml</se:Format>
              </se:ExternalGraphic>
              <!--Well known marker fallback-->
              <se:Mark>
                <se:WellKnownName>square</se:WellKnownName>
                <se:Fill>
                  <se:SvgParameter name="fill">#232323</se:SvgParameter>
                </se:Fill>
                <se:Stroke>
                  <se:SvgParameter name="stroke">#232323</se:SvgParameter>
                  <se:SvgParameter name="stroke-width">0.2</se:SvgParameter>
                </se:Stroke>
              </se:Mark>
              <se:Size>25</se:Size>
            </se:Graphic>
          </se:PointSymbolizer>
        </se:Rule>
        <se:Rule>
           <se:Name>Resuelta</se:Name>

           <ogc:Filter>
            <ogc:PropertyIsLike wildCard="%" singleChar="#" escapeChar="!">
            <ogc:PropertyName>linkeditorrelativo</ogc:PropertyName>
            <ogc:Literal>%href%</ogc:Literal>
            </ogc:PropertyIsLike>
           </ogc:Filter>

          <se:MinScaleDenominator>1</se:MinScaleDenominator>
          <se:MaxScaleDenominator>150000</se:MaxScaleDenominator>
          <se:PointSymbolizer>
            <se:Graphic>
             
              <se:ExternalGraphic>
                <se:OnlineResource xlink:type="simple" xlink:href="inspection_d_check.svg"/>
                <se:Format>image/svg+xml</se:Format>
              </se:ExternalGraphic>
              <!--Well known marker fallback-->
              <se:Mark>
                <se:WellKnownName>square</se:WellKnownName>
                <se:Fill>
                  <se:SvgParameter name="fill">#232323</se:SvgParameter>
                </se:Fill>
                <se:Stroke>
                  <se:SvgParameter name="stroke">#232323</se:SvgParameter>
                  <se:SvgParameter name="stroke-width">0.2</se:SvgParameter>
                </se:Stroke>
              </se:Mark>
              <se:Size>25</se:Size>
            </se:Graphic>
          </se:PointSymbolizer>
        </se:Rule>
      </se:FeatureTypeStyle>
    </UserStyle>
  </NamedLayer>
</StyledLayerDescriptor>
