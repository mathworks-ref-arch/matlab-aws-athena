# Installation

## Installing on Windows®, macOS® and Linux
The easiest way to install this package and all required dependencies is to clone the top-level repository using:

```bash
git clone --recursive https://github.com/mathworks-ref-arch/mathworks-aws-support.git
```

### Build the AWS SDK for Java components
The MATLAB code uses the AWS SDK for Java and can be built using:
```bash
cd matlab-aws-athena/Software/Java
mvn clean package
```

Once built, use the ```matlab-aws-athena/Software/MATLAB/startup.m``` function to initialize the interface which will use the AWS Credentials Provider Chain to authenticate. Please see the [relevant documentation](Authentication.md) on how to specify the credentials.

The package is now ready for use. MATLAB can be configured to call ```startup.m``` on start if preferred so that the package is always available automatically. For further details see: [https://www.mathworks.com/help/matlab/ref/startup.html](https://www.mathworks.com/help/matlab/ref/startup.html)

[//]: #  (Copyright 2019 The MathWorks, Inc.)
