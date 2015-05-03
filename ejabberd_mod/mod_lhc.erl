%%%----------------------------------------------------------------------
%%% File    : mod_lhc.erl
%%% Author  : Remigijus Kiminas <remdex@gmail.com>
%%% Purpose : Notyfy LHC about connected and unconnected operators
%%% Created : 3 May 2012 by Remigijus Kiminas <remdex@gmail.com>>
%%%
%%%
%%% ejabberd, Copyright (C) 2015   Live Helper Chat
%%%
%%% This program is free software; you can redistribute it and/or
%%% modify it under the terms of the GNU General Public License as
%%% published by the Free Software Foundation; either version 2 of the
%%% License, or (at your option) any later version.
%%%
%%% This program is distributed in the hope that it will be useful,
%%% but WITHOUT ANY WARRANTY; without even the implied warranty of
%%% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
%%% General Public License for more details.
%%%
%%% You should have received a copy of the GNU General Public License along
%%% with this program; if not, write to the Free Software Foundation, Inc.,
%%% 51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
%%%
%%%----------------------------------------------------------------------

-module(mod_lhc).

-behavior(gen_mod).
-include("ejabberd.hrl").
-include("logger.hrl").
-include("ejabberd.hrl").
-include("jlib.hrl").

-export([start/2, stop/1, on_set/4, on_unset/4]).

start(Host, _Opts) ->
   ejabberd_hooks:add(set_presence_hook, Host, ?MODULE, on_set, 50),
   ejabberd_hooks:add(unset_presence_hook, Host, ?MODULE, on_unset, 50),
   ok.

stop(Host) ->
   ejabberd_hooks:delete(set_presence_hook, Host, ?MODULE, on_set, 50),
   ejabberd_hooks:delete(unset_presence_hook, Host, ?MODULE, on_unset, 50),
   ok.

on_set(User, Server, _Resource, _Packet) ->
   LUser = jlib:nodeprep(User),
   LServer = jlib:nodeprep(Server),
   %%_SID = ejabberd_sm:get_session_pid(LUser, LServer, Resource),  
   
   Method = post,
   URL = "http://localhost:4567/xmpp-testing-json",
   Header = [],
   Type = "application/json",
   Body = "{\"action\":\"connect\",\"user\":\""++erlang:binary_to_list(LUser)++"\",\"server\":\""++erlang:binary_to_list(LServer)++"\"}",   
   HTTPOptions = [],
   Options = [],
   httpc:request(Method, {URL, Header, Type, Body}, HTTPOptions, Options),     
   ?INFO_MSG("Presence set demo compile Request was send %p",[Body]).

on_unset(User, Server, _Resource, _Packet) ->
   LUser = jlib:nodeprep(User),
   LServer = jlib:nodeprep(Server),
   Method = post,
   URL = "http://localhost:4567/xmpp-testing-json",
   Header = [],
   Type = "application/json",
   Body = "{\"action\":\"disconnect\",\"user\":\""++erlang:binary_to_list(LUser)++"\",\"server\":\""++erlang:binary_to_list(LServer)++"\"}",   
   HTTPOptions = [],
   Options = [],
   httpc:request(Method, {URL, Header, Type, Body}, HTTPOptions, Options),   
   ?INFO_MSG("Presence set demo un-set %p %p", [erlang:binary_to_list(LUser),erlang:binary_to_list(LServer)]). 	
