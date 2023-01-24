![Dingi banner](/ressources/GitHub_banner.png)

# Dingi

![GitHub](https://img.shields.io/github/license/davidclemens/Dingi)
![GitHub issues](https://img.shields.io/github/issues/davidclemens/Dingi)
![GitHub last commit](https://img.shields.io/github/last-commit/davidclemens/Dingi)
![GitHub repo size](https://img.shields.io/github/repo-size/davidclemens/Dingi)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/master?label=release)
![Travis (.com) branch](https://img.shields.io/travis/com/davidclemens/Dingi/development?label=development)
![Code Climate coverage](https://img.shields.io/codeclimate/coverage/davidclemens/Dingi)

Dingi is a MATLAB toolbox collection for data processing of marine research gear deployed by GEOMAR Helmholtz Centre for Ocean Research Kiel, Germany.

*As a dingi to a marine research vessel, this toolbox shall be the assistant to the researcher.*

:warning: :construction: —
This repository, especially the documentation is work in progress and testing and therefore reliability is in its infancy.

Maintained by David Clemens (dclemens@geomar.de)

## Installation

### Dependencies

The Dingi toolbox is written for MATLAB and is developed and tested with `MATLAB R2017b`.

Some functions depend on the [Gibbs Seawater (GSW) Oceanographic Toolbox](https://www.teos-10.org/software.htm#1) for MATLAB.

### Setup

1. Download the latest release (0.1.0b1) [here](https://github.com/davidclemens/Dingi/archive/refs/heads/release.zip).
2. Unzip the archive.
3. Rename the unzipped folder from `Dingi-release` to `Dingi` and move it to your desired location `<DingiFolder>`.
4. Add that location to your MATLAB search path by running `run <DingiFolder>/setupMATLABPath.m` in the MATLAB command line.

## Citing

Please cite as:

Clemens, D. (2022) Dingi. MATLAB toolbox for data processing of marine research gear deployments. Version 0.1.0b1. Available at [https://github.com/davidclemens/Dingi](https://github.com/davidclemens/Dingi).

## Contributing

If you want to contribute to this repository please [get in touch](mailto:dclemens@geomar.de) first to avoid duplicate work.

## License

The Dingi toolbox is licensed under the [MIT license](./LICENSE.md).
