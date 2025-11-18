# cessda.fair.metadata-uses-cessda-access-rights

[![SQAaaS badge](https://github.com/EOSC-synergy/SQAaaS/raw/master/badges/badges_150x116/badge_software_silver.png)](https://api.eu.badgr.io/public/assertions/jJHi783iTmC9rdECs3RoVA "SQAaaS silver badge achieved")

This repository contains the source code for the CESSDA community-specific FAIR test MetadataUsesCessdaAccessRights.

## Prerequisites

Java 21 or greater is required to build and run this application.

## Quick Start

1. Check prerequisites and install any required software.
2. Clone the repository to your local workspace.
3. Build the application using `mvn clean verify`.
4. Run the application using the following command:
    `mvn -Dexec.mainClass=cessda.fairtests.MetadataUsesCessdaAccessRights -Dexec.args="<CDC_URL>" org.codehaus.mojo:exec-maven-plugin:3.1.0:java`.

## Project Structure

This project uses the standard Maven project structure.

``` text
<ROOT>
├── .mvn                # Maven wrapper.
├── src                 # Contains all source code and assets for the application.
|   ├── main
|   |   ├── java        # Contains release source code of the application.
|   |   └── resources   # Contains release resources assets.
|   └── test
|       ├── java        # Contains test source code.
|       └── resources   # Contains test resource assets.
└── target              # The output directory for the build.
```

## Description

See the [Description](Description.md) file.

## Contributing

Please read [CONTRIBUTING](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

See [Semantic Versioning](https://semver.org/) for guidance.

## Contributors

You can find the list of contributors in the [CONTRIBUTORS](CONTRIBUTORS.md) file.

## License

See the [LICENSE](LICENSE.txt) file.

## CITING

See the [CITATION](CITATION.cff) file.
