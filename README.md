![Dingi banner](/ressources/GitHub_banner.png)

# Dingi
![GitHub](https://img.shields.io/github/license/davidclemens/Dingi)
![GitHub issues](https://img.shields.io/github/issues/davidclemens/Dingi)
![GitHub last commit](https://img.shields.io/github/last-commit/davidclemens/Dingi)
![GitHub repo size](https://img.shields.io/github/repo-size/davidclemens/Dingi)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/master?label=master)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/development?label=development)
![Code Climate coverage](https://img.shields.io/codeclimate/coverage/davidclemens/Dingi)

Dingi is a MATLAB toolbox collection for data processing of marine research gear deployed by GEOMAR Helmholtz Centre for Ocean Research Kiel, Germany.

*As a dingi to a marine research vessel, this toolbox shall be the assistant to the researcher.*

:warning: :construction: —
This repository, especially the documentation is work in progress and testing and therefore reliability is in its infancy.

Maintained by David Clemens (dclemens@geomar.de)

## Kits

### `AnalysisKit`
In `AnalysisKit` common types of analysis for `GearKit.gearDeployment` subclasses are implemented.

**Classes**:

`AnalysisKit.bigoFluxAnalysis` — Calculates benthic fluxes from the BIGO incubation data.

`AnalysisKit.eddyFluxAnalysis` — Calculates benthic fluxes from the Eddy Correlation lander data.


### `DataKit`
DataKit encompasses general data handling classes and definitions.

**Classes**:

`DataKit.dataPool` — A data container that is self describing.

`DataKit.Metadata.sparseBitmask` — Encodes arrays of bitmasks with up to 52 bits as sparse doubles.

`DataKit.Metadata.dataFlag` — Subclass to `DataKit.Metadata.sparseBitmask` implementing the us of data flags as defined in `DataKit.Metadata.validators.validFlag`.

`DataKit.Metadata.poolInfo` — Defines the metadata for a data pool in `DataKit.dataPool`.

`DataKit.Metadata.variable` — Defines valid variables and metadata.

`DataKit.Metadata.validators.validFlag` — Defines valid data flags for `DataKit.Metadata.dataFlag`.

`DataKit.Metadata.validators.validInfoVariableType` — Defines valid variable types for `DataKit.Metadata.poolInfo`.


### `DebuggerKit`
DebuggerKit has debugging tools that are used by the other toolboxes.

**Classes**:

`DebuggerKit.debugger` — A debugger object.

### `GearKit`
GearKit implements the representation of scientific gear that is used during measurement campaigns (field studies, cruises, lab work) in code. It has methods to import data from disk into a coherent and self describing format (`DataKit.dataPool`'s) that can be plotted, analysed and quality checked.

Each type of gear is implemented as its own class that is a subclass to `GearKit.gearDeployment`.

**Classes**:

`GearKit.bigoDeployment` — Subclass of `GearKit.gearDeployment`. Holds the data of a BIGO deployment.

`GearKit.ecDeployment` — Subclass of `GearKit.gearDeployment`. Holds the data of a Eddy Correlation lander deployment.

`GearKit.measuringDevice` — Defines a measuring device by its type and serial number, mounting location, device domain ('Chamber1','BottomWater', etc.) and world domain ('BenthicWaterColumn','Sediment', etc.).

`GearKit.measuringDeviceType` — Enumeration class used by `GearKit.measuringDevice`

`GearKit.worldDomain` — Enumeration class used by `GearKit.measuringDevice`

`GearKit.deviceDomain` — Enumeration class used by `GearKit.measuringDevice`

### `GraphKit`
GraphKit holds functionality linked to plotting data.

`GraphKit.axesGroup` — Stacks axes tightly together based on the actual data contained in the axes. Saves space if many curves correlate well. Commonly used in Paleo-disciplines.

`GraphKit.dataBrushWindow` — Allows picking of data points in a figure to mark them manually.

## Contributing
If you want to contribute to this repository please [get in touch](mailto:dclemens@geomar.de) first to avoid duplicate work.
