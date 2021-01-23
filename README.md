![MATLAB-toolboxes banner](/ressources/GitHub_banner.png)

# Dingi
![GitHub](https://img.shields.io/github/license/davidclemens/Dingi)
![GitHub issues](https://img.shields.io/github/issues/davidclemens/Dingi)
![GitHub last commit](https://img.shields.io/github/last-commit/davidclemens/Dingi)
![GitHub repo size](https://img.shields.io/github/repo-size/davidclemens/Dingi)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/master?label=master)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/development?label=development)

Dingi is a MATLAB toolbox collection for data processing of marine research gear deployed by GEOMAR Helmholtz Centre for Ocean Research Kiel, Germany.

This repository, especially the documentation is work in progress and testing and therefore reliability is in its infancy.

Maintained by David Clemens (dclemens@geomar.de)

## toolboxes

### AnalysisKit
In AnalysisKit implements common types of analysis for `GearKit.gearDeployment` instances.

### DataKit
DataKit encompasses general data handling classes and definitions.

### DebuggerKit
DebuggerKit has debugging tools that are used by the other toolboxes.

### GearKit
GearKit implements the representation of scientific gear that is used during measurement campaigns (field studies, cruises, lab work) in code. It has methods to import data from disk into a coherent and self describing format (`DataKit.dataPool`'s) that can be plotted, analysed and quality checked.

Each type of gear is implemented as its own class that is a subclass to `GearKit.gearDeployment`.

### GraphKit
GraphKit holds functionality linked to plotting data.

## Contributing
If you want to contribute to this repository please [get in touch](mailto:dclemens@geomar.de) first to avoid duplicate work.
