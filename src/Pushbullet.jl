module Pushbullet

# package code goes here

using Requests
using Compat

const PB_API_URL = "api.pushbullet.com/v2/"

function load_key(filepath="~/.pushbullet.key")
    fn = expanduser(filepath)
    open(fn, "r") do f
        chomp(readline(f))
    end
end

function rest_url(page; pbkey="")
    if isempty(pbkey)
        pbkey = load_key()
    end
    string("https://", pbkey, ":@", PB_API_URL, page)
end

function api_call(page; pbkey="")
    url = rest_url(page, pbkey=pbkey)
    response = get(url)
    if response.status == 200
        JSON.parse(response.data)
    else
        Dict{String,Any}[]
    end
end

function user(;pbkey="")
    api_call("users/me")
end

function devices(;pbkey="")
    data = api_call("devices")
    if haskey(data, "devices")
        data["devices"]
    else
        Any[]
    end
end

function push(device_iden, ptype="note", ptitle="", pbody=""; pbkey="")
    url = rest_url("pushes", pbkey=pbkey)
    push_data = @compat Dict(
        :device_iden => device_iden,
        :type => ptype,
        :title => ptitle,
        :body => pbody)
    response = post(url, json = push_data)
    response.status
end

end # module
