-module(mod_dirty_words).

-behaviour(gen_mod).
-include("logger.hrl").
-include_lib("fast_xml/include/fxml.hrl").

%% gen_mod callback
-export([
	start/2,
	stop/1
	]).

-export([
	filter_word/4]).

start(Host, Opts) ->
	FilePath = proplists:get_value(words_file, Opts),	
	ejabberd_hooks:add(user_send_packet, Host, ?MODULE, filter_word, 1),
	filter_word:start({local, word_filter}, 8, FilePath),
	?INFO_MSG("Hello. ejabberd world!", []),
	ok.


stop(Host)->
	?INFO_MSG("Bye bye, ejabberd world!", []),
	ok.


filter_word(Packet, C2SState, From, To)->
	#xmlel{ name = Name } = Packet,
	case Name of
		<<"message">> ->
			Body = fxml:get_path_s(Packet, [{elem, <<"body">>}]),
			#xmlel{ children = [{_, Content}] } = Body,
			Content2 = filter_word:filter(word_filter, Content),
			Body2 =	Body#xmlel{ children = [{xmlcdata, Content2}] },
			fxml:replace_subtag(Body2, Packet);
		_ ->
			Packet
	end.
	
