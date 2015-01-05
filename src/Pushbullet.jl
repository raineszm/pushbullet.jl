module Pushbullet

export user, devices, push_note

# package code goes here
using Requests
using JSON
using Compat

const PB_API_URL = "api.pushbullet.com/v2/"

type PushbulletException <: Exception
    page :: String
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

function rest_url(page)
    string("https://", PBKEY, ":@", PB_API_URL, page)
end

function api_call(page; method=:get, jsdata="")
    url = rest_url(page)
    if method == :get
        response = get(url)
    elseif method == :post
        response = post(url, json=jsdata)
    else
        throw(ArgumentError("method must be :get or :post"))
    end

    if response.status == 200
        JSON.parse(response.data)
    else
        throw(PushbulletException(page, method, response.status))
    end
end

function user()
    api_call("users/me")
end

function devices()
    api_call("devices")["devices"]
end

function push(device_iden, push_data)
    api_call("pushes", method=:post, jsdata=push_data)
end

function push_note(device_iden, ptitle="", pbody="")
    push_data = @compat Dict(
        :device_iden => device_iden,
        :type => "note",
        :title => ptitle,
        :body => pbody)
    push(device_iden, push_data)
end

end # module
