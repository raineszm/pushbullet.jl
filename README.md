# Pushbullet

This module allows user to push data using the [Pushbullet](http://pushbullet.com) service. It requires that the user have a Pushbullet account. The necessary Pushbullet token can be acquired from the [account settings](https://www.pushbullet.com/account) page.

## Access Token

In order to work, Pushbullet.jl expects there to be a file named `.pushbullet.key` in the user's home directory, which contains a single line consisting of their Pushbullet access token. It is recommended that this file be set as only viewable by the current user (`chmod 0600 ~/.pushbullet.key`).

## Usage

The module may be used as follows. Importing loads the access token. The user must then acquire a device id, using the `iden` or `devices` methods, and then Julia objects may be pushed to that device.

### Example

```julia
import Pushbullet
dev_id = Pushbullet.iden(nickname="iPhone")
Pushbullet.push_note(dev_id, title="Test", body="This is a test")
```
Pushbullet.jl provides the `push_note`, `push_address`, `push_link`, and `push_address` methods. Their usage should hopefully be clear from the call signatures.
