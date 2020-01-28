# AddAccount.zsh

AddAccount is a zsh script for adding an AWS account to Cloud Conformity.

## Installation

You will need the following:

- zsh
- AWS CLI
- A Cloud Conformity API secret with administration rights

## Usage

zsh AddAccount.zsh <CCAPISecret> <CCEndpointRegion> <AWSNamedProfile> <AccountName> <Environment>

    CCAPISecret: Obtain one from the Administration console and ensure it has sufficient rights to add accounts.

    CCEndpointRegion: Choice of eu-west-1, ap-southeast-2 or us-west-2.

    AWSNamedProfile: The name of an AWS CLI Profile with sufficient rights and access to services.

    AccountName: Name that will be used to identify the account in Cloud Conformity

    Environment: Environment Tag.

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Support
We provide this code as-is with no warranties or support whatsoever.

## License
[MIT] MIT License

Copyright (c) [2020] [AddAccount]

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
