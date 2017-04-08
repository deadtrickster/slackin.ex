-module(jsx_users_list_callback).

-export([init/1,
         handle_event/2,
         counts/1]).

-record(state,{state = start,
               jsx_state,
               online = 0,
               total = 0}).

init(_) ->
  #state{}.

counts(#state{state = State,
              online = Online,
              total = Total}) ->
  case State of
    members_finished ->
      {Online, Total};
    _ ->
      false
  end.

human(#{<<"id">> := <<"USLACKBOT">>}) ->
  false;
human(#{<<"is_bot">> := true}) ->
  false;
human(#{<<"deleted">> := true}) ->
  false;
human(_) ->
  true.

online(#{<<"presence">> := <<"away">>}) ->
  false;
online(_) ->
  true.

member_increments(Member) ->
  case human(Member) of
    true ->
      case online(Member) of
        true -> {1, 1};
        false -> {0, 1}
      end;
    false -> {0, 0}
  end.

handle_event({key, <<"members">>}, State) ->
  State#state{state = members_start};
handle_event(start_array, #state{state = members_start} = State) ->
  State#state{state = member_start,
              jsx_state = jsx_to_term:init([return_maps])};
handle_event(start_object, #state{state = member_start,
                                  jsx_state = JsxState} = State) ->
  State#state{state = member,
              jsx_state = jsx_to_term:handle_event(start_object, JsxState)};
handle_event(start_object, #state{state = member_end} = State) ->
  JsxState = jsx_to_term:handle_event(start_object,
                                      jsx_to_term:init([return_maps])),
  State#state{state = member,
              jsx_state = JsxState};
handle_event(end_object, #state{state = member,
                                jsx_state = JsxState,
                                online = Online,
                                total = Total} = State) ->
  case jsx_to_term:handle_event(end_object, JsxState) of
    {[{object, _}], _} = NewJsxState ->
      State#state{jsx_state = NewJsxState};
    {Member, _} when is_map(Member) ->
      {OI, TI} = member_increments(Member),
      State#state{state = member_end,
                  online = Online + OI,
                  total = Total + TI}
  end;
handle_event(Event, #state{state = member,
                           jsx_state = JsxState} = State) ->
  State#state{jsx_state = jsx_to_term:handle_event(Event, JsxState)};
handle_event(end_array, #state{state = member_end} = State) ->
  State#state{state = members_finished,
              jsx_state = undefined};
handle_event(_, #state{state = start} = State) ->
  State;
handle_event(_, #state{state = members_finished} = State) ->
  State.
