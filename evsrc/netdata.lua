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

  evsrc/netdata.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/05.

--]]

local InetServer = require('net.stream.inet').server;
local decodeJSON = require('cjson.safe').decode;
local gethostname = require('evpipe.syscall').gethostname;
--- constants
local LBRACE = ('{'):byte(1);
local HOST = '127.0.0.1';
local PORT = 4242;
--- file scope variables
local HOSTNAME = gethostname();


--- fetchHostname
-- @param self
local function fetchHostname( self )
    -- update HOSTNAME every 1000 msec
    while self.server do
        local name, err = gethostname();

        if name then
            HOSTNAME = name;
        else
            print( 'gethostname():', err );
        end

        sleep(1000);
    end
end


--- parseGraphite
-- @param self
-- @param line
local function parseGraphite( self, line )
    --
    -- format Graphite
    -- http://graphite.readthedocs.io/en/latest/feeding-carbon.html#the-plaintext-protocol
    --
    --  <metric path> <metric value> <metric timestamp><LF>
    --
    --  e.g.
    --  netdata.Ebisu-PC-0820.local.netdata.statsd_events.histograms 0.0000000 1507192569
    --

    -- TODO
    -- print( HOSTNAME );
    -- conn:send( line );
end


--- parseOpenTSDB
-- @param self
-- @param line
local function parseOpenTSDB( self, line )
    --
    -- format OpenTSDB
    -- http://opentsdb.net/docs/build/html/api_telnet/put.html
    --
    --  put <metric> <timestamp> <value> <tagk_1>=<tagv_1>[ <tagk_n>=<tagv_n>]<LF>
    --
    --  e.g.
    --  put netdata.system.load.load5 1507192565 1.9490000 host=Ebisu-PC-0820.local
    --

    -- TODO
    -- print( HOSTNAME )
    -- conn:send( line );
end


--- parseJSON
-- @param self
-- @param line
local function parseJSON( self, line )
    -- parse json
    local json, err = decodeJSON( line );

    if err then
        print( 'decode error', err );
    else
        self.evdst:send( json );
    end
end


--- handlClient
-- @param self
-- @param client
local function handleClient( self, client )
    local msg = '';

    atexit(function( err, trace )
        client:close();

        -- got error
        if err then
            print( 'error:', err );
            print( trace );
        end
    end)


    while true do
        local chunk, err = client:recv();

        if err then
            print( err );
            break
        -- closed by peer
        elseif not chunk then
            break
        -- parse message chunk
        else
            local head, tail, line;

            -- append to previous
            msg = msg .. chunk;

            -- parse each line
            head, tail, line = msg:find('([^\n]+)\n');
            if head then
                local cur;

                while head do
                    -- update cursor
                    cur = tail + 1;

                    -- parse json encoded metrics
                    if msg:byte(1) == LBRACE then
                        parseJSON( self, line );
                    -- parse OpenTSDB format
                    elseif msg:sub(1,4) == 'put ' then
                        parseOpenTSDB( self, line );
                    -- parse Graphite format
                    else
                        parseGraphite( self, line );
                    end

                    head, tail, line = msg:find('^([^\n]+)\n', cur );
                end

                msg = msg:sub( cur );
            end
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
local Netdata = {};


--- close
function Netdata:close()
    self.server:close();
    self.server = nil;
end


--- new
-- @param evdst
-- @param cfg
-- @return server
local function listen( evdst, cfg )
    local server, err = InetServer.new({
        host = cfg.host or HOST,
        port = cfg.port or PORT,
        reuseaddr = true
    });
    local self, ok;

    if err then
        return nil, err;
    end

    err = server:listen();
    if err then
        server:close();
        return nil, err;
    end

    self = setmetatable({
        evdst = evdst,
        server = server
    }, {
        __index = Netdata
    });

    -- fetch hostname
    ok, err = spawn( fetchHostname, self );
    if not ok then
        self:close();
        return nil, err;
    end

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

