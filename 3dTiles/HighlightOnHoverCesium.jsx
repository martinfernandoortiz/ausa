// onhover para 3d tiles en mapstore

const React = require('react');
const PropTypes = require('prop-types');
const { useEffect, useRef } = React;

class HighlightOnHoverCesium extends React.Component {
  static propTypes = {
    viewer: PropTypes.object, // El viewer de Cesium
    highlightColor: PropTypes.string // Color de resaltado
  };

  constructor(props) {
    super(props);
    this.handler = null; // Manejador de eventos
    this.entity = null; // Entidad resaltada
  }

  componentDidMount() {
    const { viewer, highlightColor } = this.props;

    // Configura el manejador de eventos para el hover
    this.handler = new Cesium.ScreenSpaceEventHandler(viewer.scene.canvas);

    this.handler.setInputAction((movement) => {
      const pickedObject = viewer.scene.pick(movement.endPosition);
      if (Cesium.defined(pickedObject) && pickedObject.id) {
        // Resalta la entidad
        if (this.entity) {
          this.entity.polygon.material = Cesium.Color.WHITE; // Restablece el color anterior
        }
        this.entity = pickedObject.id;
        this.entity.polygon.material = Cesium.Color.fromCssColorString(highlightColor || '#FF0000');
      } else if (this.entity) {
        // Restablece el color si no hay entidad seleccionada
        this.entity.polygon.material = Cesium.Color.WHITE;
        this.entity = null;
      }
    }, Cesium.ScreenSpaceEventType.MOUSE_MOVE);
  }

  componentWillUnmount() {
    // Limpia el manejador de eventos
    if (this.handler) {
      this.handler.destroy();
    }
  }

  render() {
    return null; // Este componente no renderiza nada en el DOM
  }
}

module.exports = HighlightOnHoverCesium;
