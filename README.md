# Pushbullet

This module allows users to push data using the [Pushbullet](http://pushbullet.com) service. It requires that the user have a Pushbullet account. The necessary Pushbullet token can be acquired from the [account settings](https://www.pushbullet.com/account) page.

## Access Token

In order to work, Pushbullet.jl expects there to be a file named `.pushbullet.key` in the user's home directory, which contains a single line consisting of their Pushbullet access token. It is recommended that this file be set as only viewable by the current user (`chmod 0600 ~/.pushbullet.key`).

## Usage

The module may be used as follows. Importing loads the access token. The user must then acquire a device id, using the `iden` or `devices` methods, and then Julia objects may be pushed to that device. The Pushbullet API is described in detail [here](http://docs.pushbullet.com).

Pushbullet.jl provides the `push_note`, `push_address`, `push_link`, and `push_address` methods. Their usage should hopefully be clear from the call signatures.

### Getting identifiers

Pushbullet.jl can match devices or identifiers by any of the attributes documented at [https://docs.pushbullet.com/#devices](on the Pushbullet website), comparing by equality, regex, or with a provided predicate function. Calls take the form

```julia
Pushbullet.devices(attr1=matcher1, attr2=matcher2, ...)
Pushbullet.iden(attr1=matcher1, attr2=matcher2, ...)
```

where `matcher1`,`matcher2`, etc., can be a `String`, `Number`, `Regex`, or a `Function` taking the JSON object of the device as an argument. `devices` returns the JSON objects of all devices satisfying the _all of_ the matchers, while `iden` returns the dev id of the first matching device (or an empty string if their is no match).


### Examples


#### Pushing notes

```julia
import Pushbullet
dev_id = Pushbullet.iden(nickname="iPhone")
Pushbullet.push_note(dev_id, title="Test", body="This is a test")
```

```julia
import Pushbullet
devs = Pushbullet.devices()
dev_id = devs[1]["iden"]
Pushbullet.push_link(dev_id, title="Pushbullet.jl", body="This repository",  url="https://github.com/raineszm/pushbullet.jl")
```
