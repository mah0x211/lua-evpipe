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

  bin/evpipe.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/05.

--]]

-- modules
local Synops = require('synops');
local Signal = require('signal');
local Main = require('evpipe.main');
local SynopsRun = Synops.run;
local unpack = unpack or table.unpack;
--- file scope variables
local USAGE = [[
evpipe - event pipe agent
Usage: evpipe [/path/to/conf/file]
]];

-- export synops APIs to global except Synops.run
for k, v in pairs( Synops ) do
    if type( k ) == 'string' and k ~= 'run' and
       type( v ) == 'function' then
        _G[k] = v;
    end
end

-- export signal number to global
for k, v in pairs( Signal ) do
    if type( k ) == 'string' and k:find('^SIG') and type( v ) == 'number' then
        _G[k] = v;
    end
end


do
    local ok, err = SynopsRun( Main, unpack( arg ) );

    if not ok then
        print(err);
        os.exit(-1);
    end
end

