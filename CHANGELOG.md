# Changelog
All notable changes to this project will be documented in this file. The format is based on [Keep a Changelog](http://keepachangelog.com/en/1.0.0/)
and this project adheres to [Semantic Versioning](http://semver.org/spec/v2.0.0.html).

## [0.6.1](https://github.com/kapost/clone_kit/compare/v0.6.0...v0.6.1) - 2024-04-17
- Fixed - defined `arel_attributes_with_values_for_create` internally to maintain gem compatibility with rails 5.2

## [0.5.2](https://github.com/kapost/clone_kit/compare/v0.5.1...v0.5.2) - 2019-04-02
- Do not hardcode classname in CloneKit::Strategies::Synchronous

## [0.5.1](https://github.com/kapost/clone_kit/compare/v0.5.0...v0.5.1) - 2018-12-20
- Added `SharedIdMap#delete` method for removing keys

## [0.5.0](https://github.com/kapost/clone_kit/compare/v0.4.2...v0.5.0) - 2018-11-20
- Allow Specification dependencies to be assigned a proc

## [0.4.2](https://github.com/kapost/clone_kit/compare/v0.4.1...v0.4.2) - 2018-11-14
### Added
- CHANGELOG
- Validation errors on embedded models when cloning
