# VSTS Website warmup

Warmup a website during deployment with VSTS. Using this plugin you'll have full control on how to warmup your website.

## Changes 1.2.1

- Fixed bug in success count [#19](https://github.com/luuksommers/vsts-website-warmup/issues/19)

## Changes 1.2.0

- Added success count, you can now setup the nummer of successfull attempts needed (default: 1)

## Changes 1.1.1

- Fix spelling mistakes (thanks to [MelGrubb](https://github.com/MelGrubb))

## Changes 1.1.0

- Updated VstsTasksSdk to version 0.11.0

## Key features

- Multiple relative paths
- Configurable retry count and times
- Throw exception when statuscode is not succesfull
- Awesome burning icon
- Ignore SSL support (thanks to [PixelByProxy](https://github.com/PixelByProxy))
- Support for basic auth websites
- Support for windows credentials (thanks to [elgorro](https://github.com/elgorro))
- Support for custom port numbers (thanks to [DLHForsberg](https://github.com/DLHForsberg))
- Support for multi root url (thanks to [BevanG](https://github.com/BevanG))
