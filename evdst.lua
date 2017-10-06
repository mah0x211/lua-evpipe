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

  evdst.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/05.

--]]

local inspect = require('util').inspect;
--- constants
local HOST = '127.0.0.1';
local PORT = 5000;


--- class EvDst
local EvDst = {};


--- close
function EvDst:close()
    self.conn:close();
end


--- send - oneway request
-- @param metrics
function EvDst:send( metrics )
    print( 'send metrics', inspect{metrics} )
end


--- reqrep
-- @param metrics
function EvDst:reqrep( metrics )
    print( 'reqrep metrics', inspect{metrics} )
end


--- new
-- @param dstcfg
-- @return dst
local function new( dstcfg )
    return setmetatable({
        hostinfo = {
            host = dstcfg.host or HOST,
            port = dstcfg.port or PORT,
            reuseaddr = true
        }
    }, {
        __index = EvDst
    });
end


return {
    new = new
};

