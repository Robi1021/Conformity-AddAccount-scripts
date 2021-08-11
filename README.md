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
    
    Conformity Account ID: Can be found in the Dashboard

    Conformity RTM Account ID: Can be found in the Dashboard

## Contributing
Pull requests are welcome. For major changes, please open an issue first to discuss what you would like to change.

## Support
We provide this code as-is with no warranties or support whatsoever.

## License
[MIT] See LICENSE file.
