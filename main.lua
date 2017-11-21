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

  main.lua
  lua-evpipe
  Created by Masatoshi Teruya on 17/10/05.

--]]

local inspect = require('util').inspect;
local signal = require('signal')
local Config = require('evpipe.config');
local EvDst = require('evpipe.evdst');
local EvSrc = require('evpipe.evsrc');

--- main
-- @param args...
local function main( pathname )
    local cfg = assert( Config.open( pathname ) );
    local evdst = EvDst.new( cfg.destination );
    local evsrc = EvSrc.new( cfg.source, evdst );

    -- wait
    signal.blockAll();
    sigwait( nil, SIGINT );
end


return main;
