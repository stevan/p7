
use v5.40;
use experimental qw[ class ];

use module qw[ org::p7::util::function ];

class Consumer {
    field $f :param :reader;

    method accept($t) { $f->($t); return }

    method and_then ($g) {
        __CLASS__->new( f => sub ($t) { $f->($t); $g->($t); return } )
    }
}

