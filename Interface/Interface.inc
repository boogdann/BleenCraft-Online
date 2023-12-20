include "units\interfase_items.INC"
include "units\interfase_text.INC"

CuruiTurn   dd  ?

CurFocus    dd  ?

backGroundAdd  dd  0.0


PLAY_text      db   'Play'
CONNECT_text   db   'Connect'
EXIT_text      db   'Exit'

BACK_text      db   'Back'
Menu_text      db   'Menu'
Continue_text  db   'Continue'
Create_text    db   'Create'
Open_text      db   'Open'

TEXT_text      db   'text'

version_text      db   'blincraft v1.0'
version_text_len  dd   $ - version_text

num_text         db    ?, ?, ?, ?

LABLE_ITEM_TURN   dd    0.0

input_ip_text      db   'server ip..'
input_ip_text_len  dd   $ - input_ip_text

tcp_port_text          db   'tcp port..'
tcp_port_text_len      dd   $ - tcp_port_text

udp_port_text          db   'udp port..'
udp_port_text_len      dd   $ - udp_port_text

input_radius_text      db   'radius..'
input_radius_text_len  dd   $ - input_radius_text

map_name_text          db   'game name..'
map_name_text_len      dd   $ - map_name_text


HOST_text db 'Host'

connection_success  db    'successful connection'
connection_success_len dd  $ - connection_success

start_host_text     db   'Starting multiplayer game'
start_host_text_len dd   $ - start_host_text

create_game_text    db   'Name for your new game'
create_game_text_len dd  $ - create_game_text

connect_text        db   'Connection data'
connect_text_len    dd   $ - connect_text

open_game_text      db    'Open saved game'
open_game_text_len  dd    $ - open_game_text

MAX_LEN_INPUT      dd  15
MIN_LEN_INPUT      dd  0

create_error       dd  0
create_error_len   dd  0

name_len_err       db  'Enter at least 4 characters..'
name_len_err_len   dd  $ - name_len_err


GameName_input     db   0, 20   dup  (?)

Space_text         db ' '
Space_text_len     dd  1


CurOpenPage        dd   0

maps_on_page       dd   3

new_map_slot_text  db   'new map slot..'
new_map_slot_text_len  dd  $ - new_map_slot_text

connection_try    db    'trying to connect..'
connection_try_len dd   $ - connection_try



world_path          db     "Worlds\", 20 dup (?)
world_path_offset   dd     7


