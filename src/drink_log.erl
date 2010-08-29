%%%-------------------------------------------------------------------
%%% File    : drink_log.erl
%%% Author  : Dan Willemsen <dan@csh.rit.edu>
%%% Purpose : 
%%%
%%%
%%% edrink, Copyright (C) 2010 Dan Willemsen
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
%%% You should have received a copy of the GNU General Public License
%%% along with this program; if not, write to the Free Software
%%% Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA
%%% 02111-1307 USA
%%%
%%%-------------------------------------------------------------------

-module (drink_log).
-behaviour (gen_server).

-export ([start_link/0]).
-export ([init/1, terminate/2, code_change/3]).
-export ([handle_call/3, handle_cast/2, handle_info/2]).

-export ([register_log_provider/1, get_logs/3, get_logs/2, get_temps/2]).

-record (state, {provider = undefined}).

start_link () ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [], []).

init ([]) ->
    {ok, #state{}}.

terminate (_Reason, _State) ->
    ok.

code_change (_OldVsn, State, _Extra) ->
    {ok, State}.

handle_cast (_Request, State) -> {noreply, State}.

handle_call ({set_log_provider, Provider}, _From, State) ->
    {reply, ok, State#state{ provider = Provider }};
handle_call ({log_provider}, _From, State) ->
    {reply, {ok, State#state.provider}, State};
handle_call (_Request, _From, State) -> {noreply, State}.

handle_info (_Info, State) -> {noreply, State}.

register_log_provider(LogProvider) when is_atom(LogProvider) ->
    gen_server:call(?MODULE, {set_log_provider, LogProvider}).

get_log_provider() ->
    case gen_server:call(?MODULE, {log_provider}) of
        {ok, Provider} -> Provider;
        _ -> undefined
    end.

get_logs(UserRef, Index, Count) ->
    case get_log_provider() of
        undefined -> {error, log_not_available};
        Provider -> Provider:get_logs(UserRef, Index, Count)
    end.

get_logs(Index, Count) ->
    case get_log_provider() of
        undefined -> {error, log_not_available};
        Provider -> Provider:get_logs(Index, Count)
    end.

get_temps(Since, Seconds) ->
    case get_log_provider() of
        undefined -> {error, log_not_available};
        Provider -> Provider:get_temps(Since, Seconds)
    end.
