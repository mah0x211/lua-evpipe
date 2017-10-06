--[[

  Copyright (C) 2017 Masatoshi Teruya

  Permission is hereby granted, free of charge, to any person obtaining a copy
  of this software and associated documentation files (the "Software"), to deal
  in the Software without restriction, including without limitation the rights
  to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
  copies of the Software, and to permit persons to whom the Software is
  furnished to do so, subject to the following conditions:

  The above copyright notice and this permission notice shall be included in
  all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
  IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
  FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
  AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
  LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
  OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
  THE SOFTWARE.

  evsrc/http.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/06.

--]]

local HttpServer = require('net.http.server');
--- constants
local HOST = '127.0.0.1';
local PORT = 8080;



--- handlClient
-- @param self
-- @param client
local function handleClient( self, client )
    atexit(function( err, trace )
        client:close();

        -- got error
        if err then
            print( 'error:', err );
            print( trace );
        end
    end)


    while true do
        local req, err = client:recv();

        if req then
            local res = self.evdst:reqrep( req );
            break;
        -- got error
        elseif err then
            print( 'error', err );
            break
        -- closed by peer
        else
            break
        end
    end
end


--- handleServer
-- @param server
-- @param conn
local function handleServer( self )
    while self.server do
        local client, err = self.server:accept();

        -- got client
        if client then
            spawn( handleClient, self, client );
        else
            print('failed to accept', err );
        end
    end
end



--- class Netdata
local Http = {};


--- close
function Http:close()
    self.server:close();
    self.server = nil;
end


--- new
-- @param evdst
-- @param cfg
-- @return server
local function listen( evdst, cfg )
    local server, err = HttpServer.new({
        host = cfg.host or HOST,
        port = cfg.host or PORT,
        reuseaddr = true
    });
    local self, ok;

    if err then
        return nil, err;
    end

    self = setmetatable({
        evdst = evdst,
        server = server
    }, {
        __index = Http
    });
    -- handle server
    ok, err = spawn( handleServer, self );
    if not ok then
        self:close();
        return nil, err;
    end

    return self;
end


return {
    listen = listen
};

