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

  lib/config.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/05.

--]]

--- modules
local inspect = require('util').inspect;
local evalfile = require('util').evalfile;
local concat = table.concat;
local pcall = pcall;


local function open( pathaname )
    local cfg = setmetatable({
        destination = {},
        source = {}
    },{
        __metatable = 1,
        __newindex = function( _, k )
            error( 'attempt to change global cofiguration', 2 )
        end
    });

    if pathaname then
        local fn, err = evalfile( pathaname, cfg );
        local ok;

        if err then
            return nil, err;
        end

        ok, err = pcall( fn );
        if not ok then
            return nil, err;
        end
    end

    return cfg;
end


return {
    open = open
};
