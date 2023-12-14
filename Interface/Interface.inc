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



