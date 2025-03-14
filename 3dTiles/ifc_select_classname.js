// Grant CesiumJS access to your ion assets
Cesium.Ion.defaultAccessToken = "INGRESA TU TOKEN";
const viewer = new Cesium.Viewer("cesiumContainer", {
  globe: false,
});

// Enable rendering the sky
viewer.scene.skyAtmosphere.show = true;

// Configure Ambient Occlusion
if (Cesium.PostProcessStageLibrary.isAmbientOcclusionSupported(viewer.scene)) {
  const ambientOcclusion = viewer.scene.postProcessStages.ambientOcclusion;
  ambientOcclusion.enabled = true;
  ambientOcclusion.uniforms.intensity = 2.0;
  ambientOcclusion.uniforms.bias = 0.1;
  ambientOcclusion.uniforms.lengthCap = 0.5;
  ambientOcclusion.uniforms.directionCount = 16;
  ambientOcclusion.uniforms.stepCount = 32;
}

// Set the initial camera view
viewer.camera.setView({
  destination: Cesium.Cartesian3.fromDegrees(-58.48299, -34.6800, 1000),
  orientation: {
    heading: Cesium.Math.toRadians(0), // Rotación horizontal (0 para norte)
    pitch: Cesium.Math.toRadians(-90), // Mirar directamente hacia abajo
    roll: 0, // Sin inclinación lateral
  },
});

// Add Photorealistic 3D tiles
let googleTileset;
try {
  googleTileset = await Cesium.Cesium3DTileset.fromIonAssetId(2275207);
  viewer.scene.primitives.add(googleTileset);
} catch (error) {
  console.log(`Error loading googleTileset: ${error}`);
}

// Declarar archTileset en un ámbito global
let archTileset;

try {
  archTileset = await Cesium.Cesium3DTileset.fromIonAssetId(3215852);
  viewer.scene.primitives.add(archTileset);
  await viewer.zoomTo(archTileset);

  // Aplicar el estilo predeterminado si existe
  const extras = archTileset.asset.extras;
  if (
    Cesium.defined(extras) &&
    Cesium.defined(extras.ion) &&
    Cesium.defined(extras.ion.defaultStyle)
  ) {
    archTileset.style = new Cesium.Cesium3DTileStyle(extras.ion.defaultStyle);
  }
} catch (error) {
  console.log("Error loading archTileset:", error);
}

// Functions to control styling
function showAll() {
  archTileset.style = new Cesium.Cesium3DTileStyle(); // Restablecer el estilo para mostrar todos los elementos
}

function showByCategory(className) {
  archTileset.style = new Cesium.Cesium3DTileStyle({
    show: `\${className} === '${className}'`, // Filtrar por la propiedad className
  });
}

// Función para ajustar la opacidad de googleTileset
function setGoogleTilesetOpacity(opacity) {
  if (googleTileset) {
    googleTileset.style = new Cesium.Cesium3DTileStyle({
      color: `color('#ffffff', ${opacity})`, // Ajusta la opacidad
    });
  }
}

// Agregar un control deslizante para ajustar la opacidad
const opacitySlider = document.createElement("input");
opacitySlider.type = "range";
opacitySlider.min = "0";
opacitySlider.max = "1";
opacitySlider.step = "0.1";
opacitySlider.value = "1"; // Opacidad inicial (completamente visible)
opacitySlider.style.width = "100px";
opacitySlider.style.margin = "5px";

// Agregar el control deslizante a la barra de herramientas
const toolbar = document.getElementById("toolbar");
toolbar.appendChild(opacitySlider);

// Escuchar cambios en el control deslizante
opacitySlider.addEventListener("input", function () {
  const opacity = parseFloat(opacitySlider.value);
  setGoogleTilesetOpacity(opacity);
});

// Add UI buttons to isolate by category
Sandcastle.addToolbarButton("Show All", function () {
  showAll();
});

Sandcastle.addToolbarButton("IfcBuildingElementProxy", function () {
  showByCategory('IfcBuildingElementProxy');
});

Sandcastle.addToolbarButton("IfcColumn", function () {
  showByCategory('IfcColumn');
});

Sandcastle.addToolbarButton("IfcWallStandardCase", function () {
  showByCategory('IfcWallStandardCase');
});

Sandcastle.addToolbarButton("IfcBeam", function () {
  showByCategory('IfcBeam');
});

Sandcastle.addToolbarButton("IfcSlab", function () {
  showByCategory('IfcSlab');
});
