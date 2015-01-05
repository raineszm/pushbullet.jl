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

function api_call(page; method=:get, jsdata="")
    url = string("https://", PBKEY, ":@", PB_API_URL, page)

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

function push(push_data)
    api_call("pushes", method=:post, jsdata=push_data)
end

function set_target!(push_data, target="")
    if isempty(target)
        push_data
    else
        push_data[:device_iden] = target
    end
end

function push_note(device_iden, ptitle="", pbody="")
    push_data = @compat Dict(
        :type => "note",
        :title => ptitle,
        :body => pbody)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_link(device_iden, ptitle="", pbody="", purl="")
    push_data = @compat Dict(
        :type => "link",
        :title => ptitle,
        :body => pbody,
        :url => purl)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_address(device_iden, pname="", paddress="")
    push_data = @compat Dict(
        :type => "address",
        :name => pname,
        :address => paddress)
    set_target!(push_data, device_iden)
    push(push_data)
end

function push_list(device_iden, ptitle="", pitems=[])
    push_data = @compat Dict(
        :type => "list",
        :title => ptitle,
        :items => pitems)
    set_target!(push_data, device_iden)
    push(push_data)
end

end # module
