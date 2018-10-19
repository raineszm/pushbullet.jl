"""
This module allows users to push data using the [Pushbullet](http://pushbullet.com) service. It requires that the user have a Pushbullet account. The necessary Pushbullet token can be acquired from the [account settings](https://www.pushbullet.com/account) page.
"""
module Pushbullet

export user, devices, push_note, push_address, push_link, push_list

using HTTP
using Compat

const PB_API_URL = "api.pushbullet.com/v2/"

type PushbulletException <: Exception
    page :: AbstractString
    method :: Symbol
    status :: Int
end

Base.showerror(io :: IO, e :: PushbulletException) =
    print(io, uppercase(string(e.method)), " ", e.page, " HTTP Error Code: ", e.status)

function load_key(filepath="~/.pushbullet.key")
    fn = expanduser(filepath)
    open(fn, "r") do f
        chomp(readline(f))
    end
end

const PBKEY = load_key()

function api_call(page; method=:get, jsdata="")
    url = string("https://", PB_API_URL, page)

    header = @compat Dict("Access-Token" => PBKEY)

    if method == :get
        response = get(url, headers=header)
    elseif method == :post
        response = post(url, json=jsdata, headers=header)
    else
        throw(ArgumentError("method must be :get or :post"))
    end

    if response.status == 200
        HTTP.json(response)
    else
        throw(PushbulletException(page, method, response.status))
    end
end

function user()
    api_call("users/me")
end

function matchattribute(device, key :: AbstractString, val :: Number)
    device[key] == val
end

function matchattribute(device, key :: AbstractString, val :: AbstractString)
    contains(device[key], val)
end

function matchattribute(device, key :: AbstractString, val :: Regex)
    ismatch(val, device[key])
end

function matchattribute(device, key :: AbstractString, predicate :: Function)
    predicate(device[key])
end

"""
Return a list of **active** devices on the supplied account which match the provided matchers. By default this returns a list of all active devices. Matchers may be provided as a *numeric value*, *string*, *regex*, or *predicate function* which will be compared ot the corresponding attribute of each device.

For example:

    Pushbullet.devices(nickname="nick")

This will return all devices with a nickname that is *exactly* `"nick"`.

We could instead call

    Pushbullet.devices(nickname=r"nick")

Which would return all devices whose nickname matches the regex `r"nick"`.

"""
function devices(;args...)
    devs = api_call("devices")["devices"]
    if isempty(args)
        filter!(dev -> dev["active"], devs)
    else
        filter!(devs) do dev
            dev["active"] && all(m -> matchattribute(dev, string(m[1]), m[2]), args)
        end
    end
end

"""
`iden` functions the same as `devices()` but returns on the `iden` attributes of the selected device objects.
"""
function iden(;args...)
    devs = devices(;args...)
    if isempty(devs)
        ""
    else
        devs[1]["iden"]
    end
end

function push(push_data)
    api_call("pushes", method=:post, jsdata=push_data)
end

function set_target!(push_data, target :: AbstractString)
    if isempty(target)
        push_data
    else
        push_data[:device_iden] = target
    end
end

function set_target!(push_data, target :: Dict{AbstractString, Any})
    set_target!(push_data, target["iden"])
end

function push_note(device_iden, title="", body="")
    push_data = @compat Dict(
        :type => "note",
        :title => title,
        :body => body)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_link(device_iden, title="", body="", url="")
    push_data = @compat Dict(
        :type => "link",
        :title => title,
        :body => body,
        :url => url)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_address(device_iden, name="", address="")
    push_data = @compat Dict(
        :type => "address",
        :name => name,
        :address => address)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_list(device_iden, title="", items=[])
    push_data = @compat Dict(
        :type => "list",
        :title => title,
        :items => items)
    set_target!(push_data, device_iden)
    push(push_data)
end

end # module
