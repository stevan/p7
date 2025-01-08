
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

class BiConsumer {
    field $f :param :reader;

    method accept($t, $u) { $f->($t, $u); return }

    method and_then ($g) {
        __CLASS__->new( f => sub ($t, $u) { $f->($t, $u); $g->($t, $u); return } )
    }
}
